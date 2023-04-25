using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Grid {
    // 网格可表示的内容：半径、所包含的顶点、包含的三角形、包含的边、包含的四边形
    public static int radius;
    public readonly List<Vertex_hex> hexes = new List<Vertex_hex>();
    public readonly List<Triangle> triangles = new List<Triangle>();
    public readonly List<Edge> edges = new List<Edge>();
    public readonly List<Vertex_mid> mids = new List<Vertex_mid>();
    public readonly List<Vertex_center> centers = new List<Vertex_center>();
    public readonly List<Quad> quads = new List<Quad>();

    public readonly List<SubQuad> subQuads = new List<SubQuad>();

    public readonly List<Vertex> vertices = new List<Vertex>();

    public readonly List<SubQuad_Cube> subQuad_Cubes = new List<SubQuad_Cube>();

    // 相邻点之间的距离
    public static float cellSize;

    
    // 对于 Marching Cube 需要创建三维点阵网格，因此需要在二维点阵的基础上，增加高度信息
    // 这里的height就相当于radius，表示高度在第几层，cellHeight则表示每一层的高度
    public static int height;
    public static float cellHeight;

    public Grid(int radius, int height, float cellSize, float cellHeight, int relaxCounts) {
        Grid.radius = radius;
        Grid.cellSize = cellSize;
        
        Grid.height = height;
        Grid.cellHeight = cellHeight;
        
        // 获取包含的顶点
        Vertex_hex.Hex(hexes);

        // 获取包含的三角形
        Triangle.Triangle_Hex(hexes, edges, mids, centers, triangles);

        // 随机组合相邻的三角形
        while (Triangle.HasNeighborTriangles(triangles)) {
            Triangle.RandomMergeTriangles(edges, mids, centers, triangles, quads);
        }

       foreach (Triangle triangle in triangles) {
            // 对于每一个三角形都细分，然后把细分得到的结果存到subQuads数组里
            triangle.SubDivide(subQuads);
       }

        foreach (Quad quad in quads) {
            // 对于每一个四边形都细分，然后把细分得到的结果存到subQuads数组里
            quad.SubDivide(subQuads);
        }

        vertices.AddRange(hexes);
        vertices.AddRange(mids);
        vertices.AddRange(centers);

        for (int i = 0; i < relaxCounts; i++) {
            foreach (SubQuad subQuad in subQuads) {
                subQuad.CalculateRelaxOffset();
            }

            foreach (Vertex vertex in vertices) {
                // currentPosition = initialPosition + offset
                vertex.Relax();
            }

            // foreach (SubQuad subQuad in subQuads) {
            //     subQuad.SubQuadRelax();
            // }
        }

        

        foreach (Vertex vertex in vertices) {
            vertex.index = vertices.IndexOf(vertex);
            vertex.BoundaryCheck();
        
            // 相当于检查每个顶点所包含的每个subQuad相邻的subQuad是哪些
            if (vertex is Vertex_hex) {
                ((Vertex_hex)vertex).NeighborSubQuadCheck();
            }

            // 对于Cube，顶点的层数是要比Cube的层数要多一层的
            for (int i = 0; i < Grid.height + 1; i++) {
                vertex.vertex_Ys.Add(new Vertex_Y(vertex, i));
            }
        }

        foreach (SubQuad subQuad in subQuads) {
            for (int i = 0; i < Grid.height; i++) {
                subQuad.subQuad_Cubes.Add(new SubQuad_Cube(subQuad, i, subQuad_Cubes));
            }
        }

        // 计算所有subQuad_Cubes的neighbor
        foreach (SubQuad subQuad in subQuads) {
            foreach (SubQuad_Cube subQuad_Cube in subQuad.subQuad_Cubes) {
                subQuad_Cube.NeighborsCheck();
            }
        }
    }

}
