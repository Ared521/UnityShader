using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;
using System;

public class Triangle {

    public readonly Vertex_hex a;
    public readonly Vertex_hex b;
    public readonly Vertex_hex c;
    public readonly Vertex_hex[] vertices;

    public readonly Edge ab;
    public readonly Edge bc;
    public readonly Edge ac;
    public readonly Edge[] edges;
    public readonly Vertex_triangleCenter center;

    public Triangle(Vertex_hex a, Vertex_hex b, Vertex_hex c, List<Edge> edges, List<Vertex_mid> mids, List<Vertex_center> centers, List<Triangle> triangles) {
        this.a = a;
        this.b = b;
        this.c = c;
        vertices = new Vertex_hex[] { a, b, c };

        // 创建边线，Grid类中有所有边的数组，每次创建边的时候，需要判断是否已经存在边，避免重复创建
        ab = Edge.FindEdge(a, b, edges);
        bc = Edge.FindEdge(b, c, edges);
        ac = Edge.FindEdge(a, c, edges);
        if (ab == null) ab = new Edge(a, b, edges, mids);
        if (bc == null) bc = new Edge(b, c, edges, mids);
        if (ac == null) ac = new Edge(a, c, edges, mids);

        this.edges = new Edge[] { ab, bc, ac };

        this.center = new Vertex_triangleCenter(this);

        // 每创建一个三角形，都要存到数组里
        triangles.Add(this);
        centers.Add(this.center);
    }

    // 一次画一圈三角形，分为内外圈  inner 和 outer
    public static void Triangle_Ring(int radius, List<Vertex_hex> hexes, List<Edge> edges, List<Vertex_mid> mids, List<Vertex_center> centers, List<Triangle> triangles) {
        List<Vertex_hex> inner = Vertex_hex.GrabRing(radius - 1, hexes);
        List<Vertex_hex> outer = Vertex_hex.GrabRing(radius, hexes);


        for (int i = 0; i < 6; i++) {
            for (int j = 0; j < radius; j++) {
                
                
                // for (int i = 0; i < outer.Length; i++) {
                //     DEBUG.Log()
                // }
                // 先画外圈圆
                // % 是因为第二个外顶点和第一个内顶点在转一圈之后会回到第0个
                Vertex_hex a = outer[i * radius + j];
                Vertex_hex b = outer[(i * radius + j + 1) % outer.Count];
                Vertex_hex c = inner[(i * (radius - 1) + j) % inner.Count];
                new Triangle(a, b, c, edges, mids, centers, triangles);

                if (j > 0) {
                    // Debug.Log(a.coord.q + "  " + a.coord.r + "  " + a.coord.s + "....." + b.coord.q + "  " + b.coord.r + "  " + b.coord.s + "...." + c.coord.q + "  " + c.coord.r + "  " + c.coord.s);
                }

                // 画内圈圆
                // 一个顶点在外圈，两个顶点在内圈的三角形
                if (j > 0) {
                    // 这里后面 -1 而不是 + 1是因为：绘制三角形的时候，是按照顺时针旋转，第一个值a，是外圈的顶点，然后第二个顶点按照顺时针旋转到内圈，这个是内圈的第一个顶点，第二个顶点还要按照顺时针旋转到第二个内圈顶点，
                    // 此时顺时针到内圈第二个顶点的时候，可以发现是第一个顶点的上方，而当初创建顶点点阵的时候，是按照顺时针创建顶点的，因此如果是 +1 的话，就应该是第一个内圈顶点的下方了，而我们应该取的是上方。所以这里应该是 - 1。
                    Vertex_hex d = inner[(i * (radius - 1) + j - 1) % inner.Count];
                    // Debug.Log(a.coord.q + "  " + a.coord.r + "  " + a.coord.s + "....." + c.coord.q + "  " + c.coord.r + "  " + c.coord.s + "...." + d.coord.q + "  " + d.coord.r + "  " + d.coord.s);
                    new Triangle(a, c, d, edges, mids, centers, triangles); 
                }
            }
        }
    }

    public static void Triangle_Hex(List<Vertex_hex> hexes, List<Edge> edges, List<Vertex_mid> mids, List<Vertex_center> centers, List<Triangle> triangles) {
        for (int i = 1; i <= Grid.radius; i++) {  
            Triangle_Ring(i, hexes, edges, mids, centers, triangles);
        }
    }

    // 判断三角形是否相邻
    public bool isNeighbor(Triangle target) {
        HashSet<Edge> intersection = new HashSet<Edge>(edges);
        intersection.IntersectWith(target.edges);
        return intersection.Count == 1;
    }

    // 找出该三角形的所有相邻三角形
    public List<Triangle> FindAllNeighborTriangles(List<Triangle> triangles) {
        List<Triangle> result = new List<Triangle>();
        foreach (Triangle triangle in triangles) {
            if (this.isNeighbor(triangle)) {
                result.Add(triangle);
            }
        }
        return result;
    }

    // 获取相邻的边
    public Edge NeighborEdge(Triangle neighbor) {
        HashSet<Edge> intersection = new HashSet<Edge>(edges);
        // IntersectWith方法：“修改”当前的 HashSet<T> 对象，以使其仅包含该对象和指定集合中存在的元素。
        intersection.IntersectWith(neighbor.edges);
        // 交集的Single值，也就是相邻的边
        return intersection.Single();
    }

    // 自身三角形中和相邻三角形不共有的顶点
    public Vertex_hex IsolateVertex_Self(Triangle neighbor) {
        HashSet<Vertex_hex> exception = new HashSet<Vertex_hex>(vertices);
        // ExceptWith方法：从当前 HashSet<T> 对象中移除指定集合中的所有元素。
        exception.ExceptWith(NeighborEdge(neighbor).hexes);
        return exception.Single();
    }

    // 相邻三角形中和自身三角形不共有的顶点
    public Vertex_hex IsolateVertex_Neighbor(Triangle neighbor) {
        HashSet<Vertex_hex> exception = new HashSet<Vertex_hex>(neighbor.vertices);
        // ExceptWith方法：从当前 HashSet<T> 对象中移除指定集合中的所有元素。
        // 这里没写错，下面一行代码就是去掉相邻三角形三个顶点中，相邻边的两个顶点，剩下的就是与当前三角形不共有的顶点了，也就是相邻三角形独有的顶点。
        exception.ExceptWith(NeighborEdge(neighbor).hexes);
        return exception.Single();
    }    

    // 合并三角形
    public void MergeNeighborTriangles(Triangle neighbor, List<Edge> edges, List<Vertex_mid> mids, List<Vertex_center> centers, List<Triangle> triangles, List<Quad> quads) {
        // 第一个点是自身三角形与neighbor的不共有顶点开始
        Vertex_hex a = IsolateVertex_Self(neighbor);
        // 第二个点是第一个点的下一个顶点；取余 % 的作用是：当第一个顶点是三角形第三个顶点的话，下一个顶点就回到了第一个顶点，因此需要一个取余操作
        Vertex_hex b = vertices[(Array.IndexOf(vertices, a) + 1) % 3];
        // 第三个点是相邻三角形与自身三角形不共有的顶点
        Vertex_hex c = IsolateVertex_Neighbor(neighbor);
        // 第四个点是相邻三角形中得到的顶点的下一个顶点
        Vertex_hex d = neighbor.vertices[(Array.IndexOf(neighbor.vertices, c) + 1) % 3];

        
        // 创建了新的四边形，需要把相邻三角形的边和边的中点，这两个相邻的三角形删除
        edges.Remove(NeighborEdge(neighbor));
        mids.Remove(NeighborEdge(neighbor).mid);
        centers.Remove(this.center);
        centers.Remove(neighbor.center);
        triangles.Remove(this);
        triangles.Remove(neighbor);

        Quad quad = new Quad(a, b, c, d, edges, centers, quads);
    }

    // 当不存在相邻三角形时，停止
    public static bool HasNeighborTriangles(List<Triangle> triangles) {
        foreach (Triangle a in triangles) {
            foreach (Triangle b in triangles) {
                if (a.isNeighbor(b)) {
                    return true;
                }
            }
        }
        return false;
    }

    // 随机抽取一个三角形，判断它是否有neighbor，如果有的话，则随机抽取一个neighbor合并
    public static void RandomMergeTriangles(List<Edge> edges, List<Vertex_mid> mids, List<Vertex_center> centers, List<Triangle> triangles, List<Quad> quads) {
        int randomIndex = UnityEngine.Random.Range(0, triangles.Count);
        // Debug.Log(randomIndex);
        List<Triangle> neighbors = triangles[randomIndex].FindAllNeighborTriangles(triangles);

        // neighbor可能有多个，那么就随机抽取一个合并
        if (neighbors.Count != 0) {
            int randomNeighborIndex = UnityEngine.Random.Range(0, neighbors.Count);
            
            triangles[randomIndex].MergeNeighborTriangles(neighbors[randomNeighborIndex], edges, mids, centers, triangles, quads);
        }
    }

    // 三角形细分
    public void SubDivide(List<SubQuad> subQuads) {
        SubQuad quad_a = new SubQuad(a, ab.mid, center, ac.mid, subQuads);
        SubQuad quad_b = new SubQuad(b, bc.mid, center, ab.mid, subQuads);
        SubQuad quad_c = new SubQuad(c, ac.mid, center, bc.mid, subQuads);

        // 将细分得到的subQuad，存到该顶点的subQuads数组中，为了后续的cursor的mesh构建
        a.subQuads.Add(quad_a);
        b.subQuads.Add(quad_b);
        c.subQuads.Add(quad_c);
        center.subQuads.Add(quad_a);
        center.subQuads.Add(quad_b);
        center.subQuads.Add(quad_c);
        ab.mid.subQuads.Add(quad_a);
        ab.mid.subQuads.Add(quad_b);
        bc.mid.subQuads.Add(quad_b);
        bc.mid.subQuads.Add(quad_c);
        ac.mid.subQuads.Add(quad_a);
        ac.mid.subQuads.Add(quad_c);

        quad_a.neighbors[1] = quad_b;
        quad_a.neighborVertices.Add(quad_b, new Vertex[] { ab.mid, center });
        quad_a.neighbors[2] = quad_c;
        quad_a.neighborVertices.Add(quad_c, new Vertex[] { ac.mid, center });
        quad_b.neighbors[1] = quad_c;
        quad_b.neighborVertices.Add(quad_c, new Vertex[] { bc.mid, center });
        quad_b.neighbors[2] = quad_a;
        quad_b.neighborVertices.Add(quad_a, new Vertex[] { ab.mid, center });
        quad_c.neighbors[1] = quad_a;
        quad_c.neighborVertices.Add(quad_a, new Vertex[] { ac.mid, center });
        quad_c.neighbors[2] = quad_b;
        quad_c.neighborVertices.Add(quad_b, new Vertex[] { bc.mid, center });

    }
}
