using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class GridGenerator : MonoBehaviour
{
    [SerializeField]
    private int radius;

    [SerializeField]
    private int height;

    [SerializeField]
    private float cellSize;

    [SerializeField]
    private float cellHeight;

    [SerializeField]
    private int relaxCounts;

    [SerializeField]
    public ModuleLibrary moduleLibrary;

    [SerializeField]
    Material moduleMaterial;

    [SerializeField]
    Material mapMaterial;

    // 网格，就相当于六边形地图
    private Grid grid;

    public List<Slot> slots;

    private WorldMaster worldMaster;
    private WaveFunctionCollpase waveFunctionCollpase;


    public float activateThresholdValue = 2f;
    public Transform sphere_ActivateTrue;
    public Transform aphere_ActivateFalse;

    private void Awake() {
        worldMaster = GetComponentInParent<WorldMaster>();
        waveFunctionCollpase = worldMaster.waveFunctionCollpase;
        
        grid = new Grid(radius, height, cellSize, cellHeight, relaxCounts);
        moduleLibrary = Instantiate(moduleLibrary);
    }

    private void Start() {
        DrawMapLines();
    }

    public void DrawMapLines() {
        GameObject map = new GameObject();
        map.transform.position = new Vector3(0, 0, 0);
        map.name = "Map";

        foreach (SubQuad subQuad in grid.subQuads) {
            GameObject line = new GameObject();
            line.name = "Line";
            line.transform.SetParent(map.transform);

            LineRenderer lineRenderer = line.AddComponent<LineRenderer>();
            lineRenderer.loop = true;
            lineRenderer.startWidth = 0.1f;
            lineRenderer.endWidth = 0.1f;
            lineRenderer.startColor = Color.blue;
            lineRenderer.endColor = Color.blue;
            lineRenderer.material = mapMaterial;
            lineRenderer.useWorldSpace = true;

            lineRenderer.positionCount = 4;
            Vector3 y_offset = new Vector3(0, 0.5f * cellHeight, 0);
            lineRenderer.SetPositions(new Vector3[] { subQuad.a.currentPosition + y_offset, subQuad.b.currentPosition + y_offset, subQuad.c.currentPosition + y_offset, subQuad.d.currentPosition + y_offset });
        }
    }

    private void Update() {


        // foreach (Vertex vertex in grid.vertices) {
        //                 foreach (Vertex_Y vertex_Y in vertex.vertex_Ys) {
        //                     if (vertex_Y.isActive == false && Vector3.Distance(vertex_Y.worldPosition, sphere_ActivateTrue.position) < activateThresholdValue && vertex_Y.isBoundary == false) {
        //                         vertex_Y.isActive = true;
        //                     }
        //                     else if (vertex_Y.isActive && Vector3.Distance(vertex_Y.worldPosition, aphere_ActivateFalse.position) < activateThresholdValue) {
        //                         vertex_Y.isActive = false;
        //                     }
        //                 }
        // }

        // foreach (SubQuad subQuad in grid.subQuads) {
        //     foreach (SubQuad_Cube subQuad_Cube in subQuad.subQuad_Cubes) {
        //         subQuad_Cube.UpdateBit();
        //         if (subQuad_Cube.pre_bit != subQuad_Cube.bit) {
        //             UpdateSlot(subQuad_Cube);
        //         }
        //     }
        // }
    }

    private void UpdateSlot(SubQuad_Cube subQuad_Cube) {
        string name = "Slot" + grid.subQuads.IndexOf(subQuad_Cube.subQuad) + "_" + subQuad_Cube.y;
        GameObject slot_GameObject;
        if (transform.Find(name)) {
            slot_GameObject = transform.Find(name).gameObject;
        }
        else {
            slot_GameObject = null;
        }

        if (slot_GameObject == null) {
            if (subQuad_Cube.bit != "00000000" && subQuad_Cube.bit != "11111111") {    
                slot_GameObject = new GameObject(name, typeof(Slot));
                slot_GameObject.transform.SetParent(transform);
                slot_GameObject.transform.localPosition = subQuad_Cube.centerPosition;
                Slot slot = slot_GameObject.GetComponent<Slot>();
                slot.Initialize(moduleLibrary, subQuad_Cube, moduleMaterial);
                slots.Add(slot);
                slot.UpdateModule(slot.possibleModules[0]);

                waveFunctionCollpase.resetSlots.Add(slot);
                waveFunctionCollpase.cur_CollapseSlots.Add(slot);
            }
        }
        else {
            Slot slot = slot_GameObject.GetComponent<Slot>();
            if (subQuad_Cube.bit == "00000000" || subQuad_Cube.bit == "11111111") {
                slots.Remove(slot);
                if (waveFunctionCollpase.resetSlots.Contains(slot)) {
                    waveFunctionCollpase.resetSlots.Remove(slot);
                }
                if (waveFunctionCollpase.cur_CollapseSlots.Contains(slot)) {
                    waveFunctionCollpase.cur_CollapseSlots.Remove(slot);
                }
                Destroy(slot_GameObject);
                Resources.UnloadUnusedAssets();
            }
            else {
                slot.ResetSlot(moduleLibrary);
                slot.UpdateModule(slot.possibleModules[0]);
                if (!waveFunctionCollpase.resetSlots.Contains(slot)) {
                    waveFunctionCollpase.resetSlots.Add(slot);
                }
                if (!waveFunctionCollpase.cur_CollapseSlots.Contains(slot)) {
                    waveFunctionCollpase.cur_CollapseSlots.Add(slot);
                }
            }
        }
    }

    public Grid GetGrid() {
        return grid;
    }

    // 根据点击来 创建/删除 模型
    public void ToggleSlot(Vertex_Y vertex_Y) {
        vertex_Y.isActive = !vertex_Y.isActive;
        foreach (SubQuad_Cube subQuad_Cube in vertex_Y.subQuad_Cubes) {
            subQuad_Cube.UpdateBit();
            UpdateSlot(subQuad_Cube);
        }
    }

    // // OnDrawGizmos在每帧调用
    // private void OnDrawGizmos() {
    //     if (grid != null) {
    //         // 遍历网格内的顶点
    //         // foreach (Vertex_hex vertex in grid.hexes) {
    //         //     Gizmos.DrawSphere(vertex.currentPosition, 0.3f);
    //         // }
    //         // Gizmos.color = Color.yellow;
    //         // foreach (Triangle triangle in grid.triangles) {
    //         //     Gizmos.DrawLine(triangle.a.currentPosition, triangle.b.currentPosition);
    //         //     Gizmos.DrawLine(triangle.b.currentPosition, triangle.c.currentPosition);
    //         //     Gizmos.DrawLine(triangle.c.currentPosition, triangle.a.currentPosition);
    //         // }
    //         // Gizmos.color = Color.green;
    //         // foreach (Quad quad in grid.quads) {
    //         //     Gizmos.DrawLine(quad.a.currentPosition, quad.b.currentPosition);
    //         //     Gizmos.DrawLine(quad.b.currentPosition, quad.c.currentPosition);
    //         //     Gizmos.DrawLine(quad.c.currentPosition, quad.d.currentPosition);
    //         //     Gizmos.DrawLine(quad.a.currentPosition, quad.d.currentPosition);
    //         // }
    //         // Gizmos.color = Color.red;
    //         // foreach (Vertex_mid mid in grid.mids) {
    //         //     Gizmos.DrawSphere(mid.currentPosition, 0.4f);
    //         // }
    //         // Gizmos.color = Color.cyan;
    //         // foreach (Vertex_center center in grid.centers) {
    //         //     Gizmos.DrawSphere(center.currentPosition, 0.4f);
    //         // }

    //         // Gizmos.color = Color.green;
    //         // foreach (SubQuad subQuad in grid.subQuads) {
    //         //     Gizmos.DrawLine(subQuad.a.currentPosition, subQuad.b.currentPosition);
    //         //     Gizmos.DrawLine(subQuad.b.currentPosition, subQuad.c.currentPosition);
    //         //     Gizmos.DrawLine(subQuad.c.currentPosition, subQuad.d.currentPosition);
    //         //     Gizmos.DrawLine(subQuad.d.currentPosition, subQuad.a.currentPosition);
    //         // }

    //         // 三维每个顶点
    //         // foreach (Vertex vertex in grid.vertices) {
    //         //     foreach (Vertex_Y vertex_Y in vertex.vertex_Ys) {
    //         //         if (vertex_Y.isActive) {
    //         //             Gizmos.color = Color.red;
    //         //             Gizmos.DrawSphere(vertex_Y.worldPosition, 0.1f);
    //         //         }
    //         //         else {
    //         //             Gizmos.color = Color.yellow;
    //         //             Gizmos.DrawSphere(vertex_Y.worldPosition, 0.05f);
    //         //         }
    //         //     }
    //         // }

            
    //         foreach (SubQuad subQuad in grid.subQuads) {
    //             foreach (SubQuad_Cube subQuad_Cube in subQuad.subQuad_Cubes) {
    //                 // 三维所有立方体网格
    //                 // Gizmos.color = Color.gray;
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[0].worldPosition, subQuad_Cube.vertex_Ys[1].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[1].worldPosition, subQuad_Cube.vertex_Ys[2].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[2].worldPosition, subQuad_Cube.vertex_Ys[3].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[3].worldPosition, subQuad_Cube.vertex_Ys[0].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[4].worldPosition, subQuad_Cube.vertex_Ys[5].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[5].worldPosition, subQuad_Cube.vertex_Ys[6].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[6].worldPosition, subQuad_Cube.vertex_Ys[7].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[7].worldPosition, subQuad_Cube.vertex_Ys[4].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[0].worldPosition, subQuad_Cube.vertex_Ys[4].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[1].worldPosition, subQuad_Cube.vertex_Ys[5].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[2].worldPosition, subQuad_Cube.vertex_Ys[6].worldPosition);
    //                 // Gizmos.DrawLine(subQuad_Cube.vertex_Ys[3].worldPosition, subQuad_Cube.vertex_Ys[7].worldPosition);

    //                 //GUI.color = Color.green;
    //                 // Handles.Label(subQuad_Cube.centerPosition, subQuad_Cube.bit);   
    //                 // Gizmos.DrawSphere(subQuad_Cube.centerPosition, 0.2f);
    //             }
    //         }
    //     }
    // }
}
