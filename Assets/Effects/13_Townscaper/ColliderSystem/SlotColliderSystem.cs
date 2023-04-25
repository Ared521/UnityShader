using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class SlotColliderSystem : MonoBehaviour
{
    private string GetSlotColliderName(Vertex_Y vertex_Y) {
        return "SlotCollider_" + vertex_Y.name;
    }
    
    public void CreateCollider(Vertex_Y vertex_Y) {
        GameObject slotCollider = new GameObject(GetSlotColliderName(vertex_Y), typeof(SlotCollider));
        slotCollider.GetComponent<SlotCollider>().vertex_Y = vertex_Y;
        slotCollider.transform.SetParent(transform);
        slotCollider.transform.localPosition = vertex_Y.worldPosition;

        // 创建顶部碰撞面 与Cursor相同，碰撞面的localposition设置为cellHeight的一半就好了
        GameObject top = new GameObject("Top_" + (vertex_Y.y + 1), typeof(MeshCollider), typeof(SlotCollider_Top));
        // collider的mesh与UI的那个cursor的mesh原理一样，直接调用mesh生成函数即可
        top.GetComponent<MeshCollider>().sharedMesh = vertex_Y.vertex.CreateMesh();
        top.layer = LayerMask.NameToLayer("SlotCollider");
        top.transform.SetParent(slotCollider.transform);
        // 起始位置是vertex_Y这个点的位置，因此加上Grid.cellHeight * 0.5f就是上表面的位置了
        top.transform.localPosition = Vector3.up * Grid.cellHeight * 0.5f;
        
        // 创建底部碰撞面
        GameObject bottom = new GameObject("Bottom_" + (vertex_Y.y + 1), typeof(MeshCollider), typeof(SlotCollider_Bottom));
        bottom.GetComponent<MeshCollider>().sharedMesh = vertex_Y.vertex.CreateMesh();
        // 注意需要将底部面反转，使之朝外，也就是物体的碰撞体都是朝外的
        bottom.GetComponent<MeshCollider>().sharedMesh.triangles = bottom.GetComponent<MeshCollider>().sharedMesh.triangles.Reverse().ToArray();
        bottom.layer = LayerMask.NameToLayer("SlotCollider");
        bottom.transform.SetParent(slotCollider.transform);
        bottom.transform.localPosition = Vector3.down * Grid.cellHeight * 0.5f;

        
        
        // 创建侧面碰撞面，并计算存储相邻块的信息，用于目标块的判断
        if (vertex_Y.vertex is Vertex_center) {
            List<Mesh> meshes = ((Vertex_center)vertex_Y.vertex).CreateSideMesh();
            for (int i = 0; i < vertex_Y.vertex.subQuads.Count; i++) {
                Vertex_Y neighbor = vertex_Y.vertex.subQuads[i].d.vertex_Ys[vertex_Y.y];
                GameObject side = new GameObject("side_" + neighbor.name, typeof(MeshCollider), typeof(SlotCollider_Side));
                side.GetComponent<SlotCollider_Side>().neighbor = neighbor;
                side.GetComponent<MeshCollider>().sharedMesh = meshes[i];
                side.layer = LayerMask.NameToLayer("SlotCollider");
                side.transform.SetParent(slotCollider.transform);
                side.transform.localPosition = Vector3.zero;
            }
        }
        else if (vertex_Y.vertex is Vertex_hex) {
            List<Mesh> meshes = ((Vertex_hex)vertex_Y.vertex).CreateSideMesh();
            for (int i = 0; i < vertex_Y.vertex.subQuads.Count; i++) {
                Vertex_Y neighbor = vertex_Y.vertex.subQuads[i].b.vertex_Ys[vertex_Y.y];
                GameObject side = new GameObject("side_" + neighbor.name, typeof(MeshCollider), typeof(SlotCollider_Side));
                side.GetComponent<SlotCollider_Side>().neighbor = neighbor;
                side.GetComponent<MeshCollider>().sharedMesh = meshes[i];
                side.layer = LayerMask.NameToLayer("SlotCollider");
                side.transform.SetParent(slotCollider.transform);
                side.transform.localPosition = Vector3.zero;
            }
        }
        else {
            List<Mesh> meshes = ((Vertex_mid)vertex_Y.vertex).CreateSideMesh();
            for (int i = 0; i < 4; i++) {
                Vertex_Y neighbor;
                if (vertex_Y.vertex == vertex_Y.vertex.subQuads[i].b) {
                    neighbor = vertex_Y.vertex.subQuads[i].c.vertex_Ys[vertex_Y.y];
                }
                else {
                    neighbor = vertex_Y.vertex.subQuads[i].a.vertex_Ys[vertex_Y.y];
                }
                GameObject side = new GameObject("side_" + neighbor.name, typeof(MeshCollider), typeof(SlotCollider_Side));
                side.GetComponent<SlotCollider_Side>().neighbor = neighbor;
                side.GetComponent<MeshCollider>().sharedMesh = meshes[i];
                side.layer = LayerMask.NameToLayer("SlotCollider");
                side.transform.SetParent(slotCollider.transform);
                side.transform.localPosition = Vector3.zero;
            }
        }
    }

    public void DestoryCollider(Vertex_Y vertex_Y) {
        Destroy(transform.Find(GetSlotColliderName(vertex_Y)).gameObject);
        Resources.UnloadUnusedAssets();
    }
}

public class SlotCollider : MonoBehaviour {
    public Vertex_Y vertex_Y;
}

public class SlotCollider_Top : MonoBehaviour {

}

public class SlotCollider_Bottom : MonoBehaviour {

}

public class SlotCollider_Side : MonoBehaviour {
    public Vertex_Y neighbor;
}