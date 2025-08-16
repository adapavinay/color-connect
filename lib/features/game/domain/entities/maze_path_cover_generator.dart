import 'dart:math';

class Pos {
  final int x; final int y;
  const Pos(this.x, this.y);
  @override String toString() => '($x,$y)';
  @override bool operator==(Object o) => o is Pos && o.x==x && o.y==y;
  @override int get hashCode => (y<<16)^x;
}

/// Generates solvable, full-coverage, non-intersecting puzzles by:
/// 1) Building a random spanning tree (perfect maze) on the n×n grid.
/// 2) Partitioning the tree into exactly k disjoint simple paths (path cover).
///    Each path is the unique route between its endpoints in the tree.
/// 3) Returning just the endpoints grid + hidden solution paths.
class MazePathCoverGenerator {
  final int n;
  final int k;
  final Random rng;
  final int minLen;

  late final List<List<bool>> _openU; // vertical edges
  late final List<List<bool>> _openL; // horizontal edges

  MazePathCoverGenerator(this.n, this.k, int seed, {this.minLen = 2})
      : rng = Random(seed) {
    _openU = List.generate(n, (_) => List<bool>.filled(n, false));
    _openL = List.generate(n, (_) => List<bool>.filled(n, false));
  }

  /// Entry
  (List<List<int?>>, List<List<Pos>>) generate() {
    _buildSpanningTreeDFS();
    final paths = _partitionIntoKPaths();
    final endpoints = List.generate(n, (_) => List<int?>.filled(n, null));
    for (var c=0;c<paths.length;c++) {
      final seg=paths[c];
      endpoints[seg.first.y][seg.first.x]=c;
      endpoints[seg.last.y][seg.last.x]=c;
    }
    return (endpoints, paths);
  }

  // ---- Spanning tree via randomized DFS ----
  void _buildSpanningTreeDFS() {
    final visited = List.generate(n, (_) => List<bool>.filled(n, false));
    final stack = <Pos>[];
    final start = Pos(rng.nextInt(n), rng.nextInt(n));
    stack.add(start);
    visited[start.y][start.x]=true;
    while (stack.isNotEmpty) {
      final cur = stack.last;
      final nbrs = _neighbors(cur.x, cur.y).where((p)=>!visited[p.y][p.x]).toList();
      _shuffle(nbrs);
      if (nbrs.isEmpty) { stack.removeLast(); continue; }
      final nxt = nbrs.first;
      _openEdge(cur, nxt);
      visited[nxt.y][nxt.x]=true;
      stack.add(nxt);
    }
  }

  Iterable<Pos> _neighbors(int x,int y) sync*{
    if (y>0) yield Pos(x,y-1);
    if (x>0) yield Pos(x-1,y);
    if (x<n-1) yield Pos(x+1,y);
    if (y<n-1) yield Pos(x,y+1);
  }

  void _openEdge(Pos a, Pos b){
    if (a.x==b.x){
      final y1=min(a.y,b.y);
      _openU[a.x][y1+1]=true;
    } else {
      final x1=min(a.x,b.x);
      _openL[x1+1][a.y]=true;
    }
  }

  void _shuffle<T>(List<T> list){
    for (int i=list.length-1;i>0;i--){
      final j=rng.nextInt(i+1);
      final t=list[i]; list[i]=list[j]; list[j]=t;
    }
  }

  bool _areConnected(Pos a, Pos b){
    if (a.x==b.x){
      final y1=min(a.y,b.y);
      return _openU[a.x][y1+1];
    } else if (a.y==b.y){
      final x1=min(a.x,b.x);
      return _openL[x1+1][a.y];
    }
    return false;
  }

  List<List<List<Pos>>> _adjacency(){
    final adj = List.generate(n, (_) => List.generate(n, (_)=><Pos>[]));
    for (int y=0;y<n;y++){
      for (int x=0;x<n;x++){
        final p=Pos(x,y);
        for (final q in _neighbors(x,y)){
          if (_areConnected(p,q)){ adj[y][x].add(q); }
        }
      }
    }
    return adj;
  }

  List<List<Pos>> _partitionIntoKPaths(){
    final adj = _adjacency();
    final usedEdge = <int>{};

    List<Pos> pathBetween(Pos s, Pos t){
      final parent = <Pos,Pos?>{};
      final q = <Pos>[s];
      parent[s]=null;
      int qi=0;
      while (qi<q.length){
        final u=q[qi++];
        if (u==t) break;
        for (final v in adj[u.y][u.x]){
          if (!parent.containsKey(v)){ parent[v]=u; q.add(v); }
        }
      }
      final out=<Pos>[];
      var cur=t;
      while (cur!=s){ out.add(cur); cur=parent[cur]!; }
      out.add(s);
      return out.reversed.toList();
    }

    int edgeKey(Pos a, Pos b){
      final ax=a.x, ay=a.y, bx=b.x, by=b.y;
      if (ay>by || (ay==by && ax>bx)){
        return (ax<<24) ^ (ay<<16) ^ (bx<<8) ^ by;
      } else {
        return (bx<<24) ^ (by<<16) ^ (ax<<8) ^ ay;
      }
    }

    List<List<int>> _dist(Pos s){
      final dist = List.generate(n, (_) => List<int>.filled(n, -1));
      final q = <Pos>[s]; dist[s.y][s.x]=0;
      int qi=0;
      while (qi<q.length){
        final u=q[qi++];
        for (final v in adj[u.y][u.x]){
          if (dist[v.y][v.x]==-1){ dist[v.y][v.x]=dist[u.y][u.x]+1; q.add(v); }
        }
      }
      return dist;
    }

    bool _adj(Pos a, Pos b)=> (a.x-b.x).abs()+(a.y-b.y).abs()==1;
    void _attachChain(List<List<Pos>> paths, List<Pos> chain, Pos attachTo){
      for (int i=0;i<paths.length;i++){
        final p=paths[i];
        if (p.first==attachTo){ paths[i]=[...chain.reversed, ...p]; return; }
        if (p.last==attachTo){ paths[i]=[...p, ...chain]; return; }
        final idx=p.indexOf(attachTo);
        if (idx!=-1){ paths[i]=[...p.sublist(0,idx+1), ...chain.reversed, ...p.sublist(idx+1)]; return; }
      }
      paths.add(chain);
    }

    // Pair farthest leaves first for long varied shapes
    final deg = List.generate(n, (_) => List<int>.filled(n, 0));
    for (int y=0;y<n;y++) for (int x=0;x<n;x++) deg[y][x]=adj[y][x].length;
    final leaves=<Pos>[];
    for (int y=0;y<n;y++) for (int x=0;x<n;x++) if (deg[y][x]<=1) leaves.add(Pos(x,y));
    final leafPool=leaves.toList(); _shuffle(leafPool);
    final paths=<List<Pos>>[];

    while (leafPool.isNotEmpty && paths.length<k*2){
      final s = leafPool.removeLast();
      final dist=_dist(s);
      Pos? best; int bestD=-1, bestI=-1;
      for (int i=0;i<leafPool.length;i++){
        final t=leafPool[i];
        final d=dist[t.y][t.x];
        if (d>bestD){ best=t; bestD=d; bestI=i; }
      }
      if (best==null) break;
      leafPool.removeAt(bestI);
      final pth=pathBetween(s,best);
      if (pth.length>=minLen){
        bool ok=true;
        for (int i=1;i<pth.length;i++){
          final kkey=edgeKey(pth[i-1], pth[i]);
          if (usedEdge.contains(kkey)){ ok=false; break; }
        }
        if (ok){
          for (int i=1;i<pth.length;i++) usedEdge.add(edgeKey(pth[i-1], pth[i]));
          paths.add(pth);
        }
      }
    }

    // Cover remaining nodes by attaching chains to nearest paths
    final covered = List.generate(n, (_) => List<bool>.filled(n, false));
    for (final seg in paths) for (final p in seg) covered[p.y][p.x]=true;
    for (int y=0;y<n;y++){
      for (int x=0;x<n;x++){
        if (covered[y][x]) continue;
        final chain=<Pos>[];
        Pos cur=Pos(x,y); Pos? prev;
        while (true){
          chain.add(cur); covered[cur.y][cur.x]=true;
          final nbrs = [for (final v in adj[cur.y][cur.x]) if (prev==null || v!=prev) v];
          if (nbrs.isEmpty) break;
          if (covered[nbrs.first.y][nbrs.first.x]){ _attachChain(paths, chain, nbrs.first); break; }
          prev=cur; cur=nbrs.first;
        }
      }
    }

    // Adjust to exactly k paths
    if (paths.length > k){
      paths.sort((a,b)=>a.length.compareTo(b.length));
      bool merged=true; int guard=1000;
      while (paths.length>k && merged && guard-->0){
        merged=false;
        outer: for (int i=0;i<paths.length;i++){
          for (int j=i+1;j<paths.length;j++){
            final A=paths[i], B=paths[j];
            if (_adj(A.last,B.first)){
              paths.removeAt(j); paths.removeAt(i); paths.add([...A, ...B]); merged=true; break outer;
            } else if (_adj(A.first,B.first)){
              paths.removeAt(j); paths.removeAt(i); paths.add([...A.reversed, ...B]); merged=true; break outer;
            } else if (_adj(A.last,B.last)){
              paths.removeAt(j); paths.removeAt(i); paths.add([...A, ...B.reversed]); merged=true; break outer;
            } else if (_adj(A.first,B.last)){
              paths.removeAt(j); paths.removeAt(i); paths.add([...A.reversed, ...B.reversed]); merged=true; break outer;
            }
          }
        }
      }
    } else if (paths.length < k){
      int guard=1000;
      while (paths.length<k && guard-->0){
        paths.sort((a,b)=>b.length.compareTo(a.length));
        final L=paths.removeAt(0);
        if (L.length<minLen*2){ paths.add(L); break; }
        final cut = minLen + rng.nextInt(L.length - minLen*1 - 1);
        paths.add(L.sublist(0,cut));
        paths.add(L.sublist(cut));
      }
    }

    _shuffle(paths);
    return paths;
  }
}
