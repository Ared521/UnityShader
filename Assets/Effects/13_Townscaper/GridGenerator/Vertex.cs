using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class Vertex {
    // 每个点在世界中的初始位置，方便后续的网格平滑
    public Vector3 initialPosition;
    public Vector3 currentPosition;
    public Vector3 offset = Vector3.zero;
    public int index;
    public List<SubQuad> subQuads = new List<SubQuad>();

    public bool isBoundary;
    
    // 此时，对于每一个Vertex顶点，其实都是包含了一个竖直方向的Vertex数组，包括最下层的位置
    public List<Vertex_Y> vertex_Ys = new List<Vertex_Y>();

    public void Relax() {
        currentPosition = initialPosition + offset;
    }

    public void BoundaryCheck() {
        // 判断该点(Hex)是否为边缘
        bool isBoundaryHex = this is Vertex_hex && ((Vertex_hex)this).coord.radius == Grid.radius;
        // 判断该点(Mid)是否为边缘
        bool isBoundaryMid = this is Vertex_mid && ((Vertex_mid)this).edge.hexes.ToArray()[0].coord.radius == Grid.radius && ((Vertex_mid)this).edge.hexes.ToArray()[1].coord.radius == Grid.radius;
        isBoundary = isBoundaryHex || isBoundaryMid;
    }

    // 根据鼠标Cursor所在的顶点，创建这个顶点所覆盖的Mesh
    public Mesh CreateMesh() {
        // 根据Vertex所包含的subQuad，来创建cursor的mesh
        List<Vector3> meshVertices = new List<Vector3>();
        List<int> meshTriangles = new List<int>();

        foreach (SubQuad subQuad in subQuads) {
            if (this is Vertex_center) {
                meshVertices.Add(currentPosition);
                meshVertices.Add(subQuad.GetMid_cd());
                meshVertices.Add(subQuad.GetCenterPosition());
                meshVertices.Add(subQuad.GetMid_bc());
            }
            else if (this is Vertex_mid) {
                if (subQuad.b == this) {
                    meshVertices.Add(currentPosition);
                    meshVertices.Add(subQuad.GetMid_bc());
                    meshVertices.Add(subQuad.GetCenterPosition());
                    meshVertices.Add(subQuad.GetMid_ab());
                }
                else if (subQuad.d == this) {
                    meshVertices.Add(currentPosition);
                    meshVertices.Add(subQuad.GetMid_ad());
                    meshVertices.Add(subQuad.GetCenterPosition());
                    meshVertices.Add(subQuad.GetMid_cd());
                }
            }
            else {
                meshVertices.Add(currentPosition);
                meshVertices.Add(subQuad.GetMid_ab());
                meshVertices.Add(subQuad.GetCenterPosition());
                meshVertices.Add(subQuad.GetMid_ad());
            }
        }
        // 因为后续要给这个mesh重新赋予位置，所以这里要用到相对于当前vertex位置的偏移值
        for (int i = 0; i < meshVertices.Count; i++) {
                meshVertices[i] -= currentPosition;
            }
        for (int i = 0; i < subQuads.Count; i++) {
            meshTriangles.Add(i * 4 + 0);
            meshTriangles.Add(i * 4 + 1);
            meshTriangles.Add(i * 4 + 2);
            meshTriangles.Add(i * 4 + 0);
            meshTriangles.Add(i * 4 + 2);
            meshTriangles.Add(i * 4 + 3);
        }

        Mesh mesh = new Mesh();
        mesh.vertices = meshVertices.ToArray();
        mesh.triangles = meshTriangles.ToArray();
        return mesh;
    }
}


public class Coord {
    public readonly int q;
    public readonly int r;
    public readonly int s;
    public readonly int radius;
    public readonly Vector3 worldPosition;
    
    public Coord(int q, int r, int s) {
        this.q = q;
        this.r = r;
        this.s = s;
        this.radius = Mathf.Max(Mathf.Abs(q), Mathf.Abs(r), Mathf.Abs(s));
        worldPosition = WorldPosition();
    }

    public Vector3 WorldPosition() {
        // 以 +q 为 z 轴
        // return new Vector3(r * Mathf.Sqrt(3) / 2, 0, (float)q + ((float)r / 2)) * 2 * Grid.cellSize;

        // 以 +q 为 x 轴
        return new Vector3(q * Mathf.Sqrt(3) / 2, 0, -(float)r - ((float)q / 2)) * 2 * Grid.cellSize;
    }

    static public Coord[] directions = new Coord[] {
        new Coord(0, 1, -1),
        new Coord(-1, 1, 0),
        new Coord(-1, 0, 1),
        new Coord(0, -1, 1),
        new Coord(1, -1, 0),
        new Coord(1, 0, -1)
    };

    static public Coord Direction(int direction) {
        return Coord.directions[direction];
    }

    public Coord Add(Coord coord) {
        // coord .qrs 相当于单位长度，根据radius多次累加
        return new Coord(q + coord.q, r + coord.r, s + coord.s);
    }

    // 根据输入的raduis，来scale坐标。
    public Coord Scale(int k) {
        return new Coord(q * k, r * k, s * k);
    }

    // 当radius大于1时，根据当前旋转方向获取下一个位置的坐标
    public Coord Neighbor(int direction) {
        return Add(Direction(direction));
    }
    
    // Single Ring
    public static List<Coord> Coord_Ring(int radius) {
        List<Coord> result = new List<Coord>();
        if (radius == 0) {
            result.Add(new Coord(0, 0, 0));
        }
        else {
            // direction = 4 是起始点
            Coord coord = Coord.Direction(4).Scale(radius);
            for (int i = 0; i < 6; i++) {
                for (int j = 0; j < radius; j++) {
                    result.Add(coord);
                    // 获取下一个点的位置
                    coord = coord.Neighbor(i);
                }
            }
        }
        return result;
    }

    // 根据radius，创建六边形点阵坐标
    public static List<Coord> Coord_Hex() {
        List<Coord> result = new List<Coord>();
        for (int i = 0; i <= Grid.radius; i++) {
            result.AddRange(Coord_Ring(i));
        }
        return result;
    }
}

public class Vertex_hex : Vertex {
    
    public readonly Coord coord;
    
    public Vertex_hex(Coord coord) {
        this.coord = coord;
        initialPosition = coord.worldPosition;
        currentPosition = initialPosition;
    }

    public static void Hex(List<Vertex_hex> vertices) {
        foreach (Coord coord in Coord.Coord_Hex()) {
            vertices.Add(new Vertex_hex(coord));
        }
    }

    // 获取半径为radius的Single_Ring中的所有点
    public static List<Vertex_hex> GrabRing(int radius, List<Vertex_hex> vertices) {
        if (radius == 0) {
            return vertices.GetRange(0, 1);
        }
        else {
            return vertices.GetRange(radius * (radius - 1) * 3 + 1, radius * 6);
        }
    }

    public List<Mesh> CreateSideMesh() {
        // 当顶点是顶点类时
        int n = this.subQuads.Count;
        List<Mesh> meshes = new List<Mesh>();

        for (int i = 0; i < n; i++) {
            List<Vector3> meshVertices = new List<Vector3>();
            List<int> meshTriangles = new List<int>();

            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
            
            meshVertices.Add(subQuads[i].GetMid_ab() + Vector3.up * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[i].GetMid_ab() + Vector3.down * Grid.cellHeight * 0.5f);

            // 最后两个顶点需要找到与对应subQuad的b点相同的d点的subQuad来获得
            foreach (SubQuad subQuad in subQuads) {
                if (subQuad.d == subQuads[i].b) {
                    meshVertices.Add(subQuad.GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
                    meshVertices.Add(subQuad.GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
                    break;
                }
            }

            for (int j = 0; j < meshVertices.Count; j++) {
                // 跟之前一样，只获取相对偏移值即可
                meshVertices[j] -=currentPosition;
            }
            
            meshTriangles.Add(0);
            meshTriangles.Add(2);
            meshTriangles.Add(1);
            meshTriangles.Add(2);
            meshTriangles.Add(3);
            meshTriangles.Add(1);
            meshTriangles.Add(2);
            meshTriangles.Add(4);
            meshTriangles.Add(5);
            meshTriangles.Add(2);
            meshTriangles.Add(5);
            meshTriangles.Add(3);
            
            Mesh mesh = new Mesh();
            mesh.vertices = meshVertices.ToArray();
            mesh.triangles = meshTriangles.ToArray();
            meshes.Add(mesh);
        }
        // 因为有多个subQuad，最终组合成一个完整的mesh
        return meshes;
    }

    public void NeighborSubQuadCheck() {
        foreach (SubQuad subquad_a in subQuads) {
            foreach (SubQuad subQuad_b in subQuads) {
                if (subquad_a.b == subQuad_b.d) {
                    subquad_a.neighbors[0] = subQuad_b;
                    subquad_a.neighborVertices.Add(subQuad_b, new Vertex[] { subquad_a.b, subquad_a.a });
                    break;
                }
            }
            foreach (SubQuad subQuad_b in subQuads) {
                if (subquad_a.d == subQuad_b.b) {
                    subquad_a.neighbors[3] = subQuad_b;
                    subquad_a.neighborVertices.Add(subQuad_b, new Vertex[] { subquad_a.d, subquad_a.a });
                    break;
                }
            }
        }
    }
}

// 边的中点
public class Vertex_mid : Vertex {
    public readonly Edge edge;
    public Vertex_mid(Edge edge, List<Vertex_mid> mids) {
        this.edge = edge;
        Vertex_hex a = edge.hexes.ToArray()[0];
        Vertex_hex b = edge.hexes.ToArray()[1];
        initialPosition = (a.initialPosition + b.initialPosition) / 2;
        currentPosition = initialPosition;
        
        mids.Add(this);
    }

    public List<Mesh> CreateSideMesh() {
        // 当顶点是vertex_mid类时
        List<Mesh> meshes = new List<Mesh>();

        for (int i = 0; i < 4; i++) {
            List<Vector3> meshVertices = new List<Vector3>();
            List<int> meshTriangles = new List<int>();

            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
            
            if (subQuads[i].b == this) {
                meshVertices.Add(subQuads[i].GetMid_bc() + Vector3.up * Grid.cellHeight * 0.5f);
                meshVertices.Add(subQuads[i].GetMid_bc() + Vector3.down * Grid.cellHeight * 0.5f);
                
                foreach (SubQuad subQuad in subQuads) {
                    if (subQuad.c == subQuads[i].c && subQuad != subQuads[i]) {
                        meshVertices.Add(subQuad.GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
                        meshVertices.Add(subQuad.GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
                        break;
                    }
                }
            }

            else {
                meshVertices.Add(subQuads[i].GetMid_ad() + Vector3.up * Grid.cellHeight * 0.5f);
                meshVertices.Add(subQuads[i].GetMid_ad() + Vector3.down * Grid.cellHeight * 0.5f);
                
                foreach (SubQuad subQuad in subQuads) {
                    if (subQuad.a == subQuads[i].a && subQuad != subQuads[i]) {
                        meshVertices.Add(subQuad.GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
                        meshVertices.Add(subQuad.GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
                        break;
                    }
                }
            }

            for (int j = 0; j < meshVertices.Count; j++) {
                // 跟之前一样，只获取相对偏移值即可
                meshVertices[j] -=currentPosition;
            }
            
            meshTriangles.Add(0);
            meshTriangles.Add(2);
            meshTriangles.Add(1);
            meshTriangles.Add(2);
            meshTriangles.Add(3);
            meshTriangles.Add(1);
            meshTriangles.Add(2);
            meshTriangles.Add(4);
            meshTriangles.Add(5);
            meshTriangles.Add(2);
            meshTriangles.Add(5);
            meshTriangles.Add(3);
            
            Mesh mesh = new Mesh();
            mesh.vertices = meshVertices.ToArray();
            mesh.triangles = meshTriangles.ToArray();
            meshes.Add(mesh);
        }
        // 因为有多个subQuad，最终组合成一个完整的mesh
        return meshes;
    }
}

public class Vertex_center : Vertex {
    
        public List<Mesh> CreateSideMesh() {
        // 当顶点是center类时
        int n = this.subQuads.Count;
        List<Mesh> meshes = new List<Mesh>();

        for (int i = 0; i < n; i++) {
            List<Vector3> meshVertices = new List<Vector3>();
            List<int> meshTriangles = new List<int>();

            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[i].GetMid_cd() + Vector3.up * Grid.cellHeight * 0.5f);
            // 相当于逆时针，取当前subQuad的上一个subQuad
            meshVertices.Add(subQuads[(i - 1 + n) % n].GetCenterPosition() + Vector3.up * Grid.cellHeight * 0.5f);
            
            meshVertices.Add(subQuads[i].GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[i].GetMid_cd() + Vector3.down * Grid.cellHeight * 0.5f);
            meshVertices.Add(subQuads[(i - 1 + n) % n].GetCenterPosition() + Vector3.down * Grid.cellHeight * 0.5f);

            for (int j = 0; j < meshVertices.Count; j++) {
                // 跟之前一样，只获取相对偏移值即可
                meshVertices[j] -=currentPosition;
            }
            
            meshTriangles.Add(0);
            meshTriangles.Add(1);
            meshTriangles.Add(3);
            meshTriangles.Add(1);
            meshTriangles.Add(4);
            meshTriangles.Add(3);
            meshTriangles.Add(1);
            meshTriangles.Add(2);
            meshTriangles.Add(5);
            meshTriangles.Add(1);
            meshTriangles.Add(5);
            meshTriangles.Add(4);
            
            Mesh mesh = new Mesh();
            mesh.vertices = meshVertices.ToArray();
            mesh.triangles = meshTriangles.ToArray();
            meshes.Add(mesh);
        }
        // 因为有多个subQuad，最终组合成一个完整的mesh
        return meshes;
    }
}

// 三角形中点
public class Vertex_triangleCenter : Vertex_center {
    public Vertex_triangleCenter(Triangle triangle) {
        initialPosition = (triangle.a.initialPosition + triangle.b.initialPosition + triangle.c.initialPosition) / 3;
        currentPosition = initialPosition;
    }
}

// 四边形中点
public class Vertex_quadCenter : Vertex_center {
    public Vertex_quadCenter(Quad quad) {
        initialPosition = (quad.a.initialPosition + quad.b.initialPosition + quad.c.initialPosition + quad.d.initialPosition) / 4;
        currentPosition = initialPosition;
    }
}


// 需要在二维点阵的基础上，也就是每个顶点，创建一个高度值
public class Vertex_Y {
    public readonly Vertex vertex;
    public readonly int y;
    public readonly string name;
    public readonly Vector3 worldPosition;
    public bool isBoundary;

    public bool isActive;
    public List<SubQuad_Cube> subQuad_Cubes = new List<SubQuad_Cube>();
    
    public Vertex_Y(Vertex vertex, int y) {
        this.vertex = vertex;
        this.y = y;
        this.name = "Vertex_" + vertex.index + "_" + y;
        this.isBoundary = vertex.isBoundary || y == Grid.height || y == 0;
        worldPosition = vertex.currentPosition + Vector3.up * (y * Grid.cellHeight);
    }
}