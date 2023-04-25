using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SubQuad {
    // 需要按照顺时针的方式，绘制四边形，
    public readonly Vertex_hex a;
    public readonly Vertex_mid b;
    public readonly Vertex_center c;
    public readonly Vertex_mid d;

    // 这里的意思是对于地图的每个subQuad，竖直方向上所有的subQuad_Cube都会存在这个数组里。
    public List<SubQuad_Cube> subQuad_Cubes = new List<SubQuad_Cube>();

    public Dictionary<SubQuad, Vertex[]> neighborVertices = new Dictionary<SubQuad, Vertex[]>();

    public SubQuad[] neighbors = new SubQuad[4];

    public SubQuad(Vertex_hex a, Vertex_mid b, Vertex_center c, Vertex_mid d, List<SubQuad> subQuads) {
        this.a = a;
        this.b = b;
        this.c = c;
        this.d = d;

        subQuads.Add(this);
    }

    public void CalculateRelaxOffset() {
        Vector3 center = (a.currentPosition + b.currentPosition + c.currentPosition + d.currentPosition) / 4;

        // A坐标平滑后的值
        Vector3 vector_a = (a.currentPosition
                            + center + Quaternion.AngleAxis(270, Vector3.up) * (b.currentPosition - center)
                            + center + Quaternion.AngleAxis(180, Vector3.up) * (c.currentPosition - center)
                            + center + Quaternion.AngleAxis(90, Vector3.up) * (d.currentPosition - center)) / 4;

        
        Vector3 vector_b = center + Quaternion.AngleAxis(-270, Vector3.up) * (vector_a - center);
        Vector3 vector_c = center + Quaternion.AngleAxis(-180, Vector3.up) * (vector_a - center);
        Vector3 vector_d = center + Quaternion.AngleAxis(-90, Vector3.up) * (vector_a - center);

        // 0.1f 是偏移系数
        a.offset += (vector_a - a.currentPosition) * 0.1f;
        b.offset += (vector_b - b.currentPosition) * 0.1f;
        c.offset += (vector_c - c.currentPosition) * 0.1f;
        d.offset += (vector_d - d.currentPosition) * 0.1f;
    }

    public Vector3 GetMid_ab() {
        return (a.currentPosition + b.currentPosition) / 2;
    }
    public Vector3 GetMid_bc() {
        return (b.currentPosition + c.currentPosition) / 2;
    }
    public Vector3 GetMid_cd() {
        return (c.currentPosition + d.currentPosition) / 2;
    }
    public Vector3 GetMid_ad() {
        return (a.currentPosition + d.currentPosition) / 2;
    }

    public void SubQuadRelax() {
        a.currentPosition = a.initialPosition + a.offset;
        b.currentPosition = b.initialPosition + b.offset;
        c.currentPosition = c.initialPosition + c.offset;
        d.currentPosition = d.initialPosition + d.offset;
    }

    public Vector3 GetCenterPosition() {
        return (a.currentPosition + b.currentPosition +c.currentPosition + d.currentPosition) / 4;
    }
}

public class SubQuad_Cube {
    // 标志着这个三维立方体网格SubQuad_Cube是属于地图上哪个subQuad
    public readonly SubQuad subQuad;
    public readonly int y;
    public int index;

    // 三维立方体网格的中心点
    public readonly Vector3 centerPosition;

    public readonly Vertex_Y[] vertex_Ys = new Vertex_Y[8];
    public SubQuad_Cube[] neighbors = new SubQuad_Cube[6];

    public Dictionary<SubQuad_Cube, Vertex_Y[]> neighborVertices = new Dictionary<SubQuad_Cube, Vertex_Y[]>();

    public string bit = "00000000";
    public string pre_bit = "00000000";

    public bool isActive;
    public Slot slot;

    public SubQuad_Cube(SubQuad subQuad, int y, List<SubQuad_Cube> subQuad_Cubes) {
        this.subQuad = subQuad;
        this.y = y;
        subQuad_Cubes.Add(this);
        index = subQuad_Cubes.IndexOf(this);

        centerPosition = subQuad.GetCenterPosition() + Vector3.up * Grid.cellHeight * (y + 0.5f);

        vertex_Ys[0] = subQuad.a.vertex_Ys[y + 1];
        vertex_Ys[1] = subQuad.b.vertex_Ys[y + 1];
        vertex_Ys[2] = subQuad.c.vertex_Ys[y + 1];
        vertex_Ys[3] = subQuad.d.vertex_Ys[y + 1];
        vertex_Ys[4] = subQuad.a.vertex_Ys[y];
        vertex_Ys[5] = subQuad.b.vertex_Ys[y];
        vertex_Ys[6] = subQuad.c.vertex_Ys[y];
        vertex_Ys[7] = subQuad.d.vertex_Ys[y];

        // 这里的意思是，对于每个vertex_Ys[i]，都存储它所会影响到的SubQuad_Cube，到时候一旦这个vertex_Ys[i]改变状态，就会影响它这个SubQuad_Cube数组里的值
        foreach (Vertex_Y vertex_Y in vertex_Ys) {
            vertex_Y.subQuad_Cubes.Add(this);
        }
    }


    // 只有Vertex_Y这个类中定义了是否被激活的成员变量，因此判断bit，都是在Vertex_Y实例中判断
    public void UpdateBit() {
        pre_bit = bit;
        string res = "";
        for (int i = 0; i < 8; i++) {
            if (vertex_Ys[i].isActive) {
                res += "1";
            }
            else {
                res += "0";
            }
        }
        bit = res;

        if (bit == "00000000") {
            isActive = false;
        }
        else {
            isActive = true;
        }
    }

    // 求出每个subQuad_Cube六个面的neighbor
    public void NeighborsCheck() {
        if (subQuad.neighbors[0] != null) {
            neighbors[0] = subQuad.neighbors[0].subQuad_Cubes[y];
            neighborVertices.Add(neighbors[0], new Vertex_Y[] { subQuad.neighborVertices[subQuad.neighbors[0]][0].vertex_Ys[y], subQuad.neighborVertices[subQuad.neighbors[0]][1].vertex_Ys[y],
                                                            subQuad.neighborVertices[subQuad.neighbors[0]][0].vertex_Ys[y + 1], subQuad.neighborVertices[subQuad.neighbors[0]][1].vertex_Ys[y + 1] });
        }
        if (subQuad.neighbors[1] != null) {
            neighbors[1] = subQuad.neighbors[1].subQuad_Cubes[y];
            neighborVertices.Add(neighbors[1], new Vertex_Y[] { subQuad.neighborVertices[subQuad.neighbors[1]][0].vertex_Ys[y], subQuad.neighborVertices[subQuad.neighbors[1]][1].vertex_Ys[y],
                                                            subQuad.neighborVertices[subQuad.neighbors[1]][0].vertex_Ys[y + 1], subQuad.neighborVertices[subQuad.neighbors[1]][1].vertex_Ys[y + 1] });
        }
        if (subQuad.neighbors[2] != null) {
            neighbors[2] = subQuad.neighbors[2].subQuad_Cubes[y];
            neighborVertices.Add(neighbors[2], new Vertex_Y[] { subQuad.neighborVertices[subQuad.neighbors[2]][0].vertex_Ys[y], subQuad.neighborVertices[subQuad.neighbors[2]][1].vertex_Ys[y],
                                                            subQuad.neighborVertices[subQuad.neighbors[2]][0].vertex_Ys[y + 1], subQuad.neighborVertices[subQuad.neighbors[2]][1].vertex_Ys[y + 1] });
        }
        if (subQuad.neighbors[3] != null) {
            neighbors[3] = subQuad.neighbors[3].subQuad_Cubes[y];
            neighborVertices.Add(neighbors[3], new Vertex_Y[] { subQuad.neighborVertices[subQuad.neighbors[3]][0].vertex_Ys[y], subQuad.neighborVertices[subQuad.neighbors[3]][1].vertex_Ys[y],
                                                            subQuad.neighborVertices[subQuad.neighbors[3]][0].vertex_Ys[y + 1], subQuad.neighborVertices[subQuad.neighbors[3]][1].vertex_Ys[y + 1] });
        }

        if (y < Grid.height - 1) {
            neighbors[4] = subQuad.subQuad_Cubes[y + 1];
            neighborVertices.Add(neighbors[4], new Vertex_Y[] { vertex_Ys[4], vertex_Ys[5], vertex_Ys[6], vertex_Ys[7] });
        }
        if (y > 0) {
            neighbors[5] = subQuad.subQuad_Cubes[y - 1];
            neighborVertices.Add(neighbors[5], new Vertex_Y[] { vertex_Ys[0], vertex_Ys[1], vertex_Ys[2], vertex_Ys[3] });
        }
    }
}
