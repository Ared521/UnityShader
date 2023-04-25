using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

[SelectionBase]
public class Slot : MonoBehaviour
{   
    
    public List<Module> possibleModules;
    
    public SubQuad_Cube subQuad_Cube;
    public GameObject module;

    public bool reset;

    public Material material;

    public Stack<List<Module>> pre_possibleModules = new Stack<List<Module>>();

    private void Awake() {
        module = new GameObject("Module", typeof(MeshFilter), typeof(MeshRenderer));
        module.transform.SetParent(transform);
        module.transform.localPosition = Vector3.zero;
    }

    public void Initialize(ModuleLibrary moduleLibrary, SubQuad_Cube subQuad_Cube, Material material) {
        this.subQuad_Cube = subQuad_Cube;
        this.subQuad_Cube.slot = this;
        this.material = material;
        ResetSlot(moduleLibrary);
    }

    public void ResetSlot(ModuleLibrary moduleLibrary) {
        // 将得到的List独立出来，不影响原有list
        possibleModules = moduleLibrary.GetModules(subQuad_Cube.bit).ConvertAll( x => x );
        reset = true;
    }

    private void RotateMoule(Mesh mesh, int rotation) {
        if (rotation != 0) {
            Vector3[] vertices = mesh.vertices;
            for (int i = 0; i < vertices.Length; i++) {
                vertices[i] = Quaternion.AngleAxis(90 * rotation, Vector3.up) * vertices[i];
            }
            mesh.vertices = vertices;
        }
    }

    private void FlipModule(Mesh mesh, bool flip) {
        if (flip) {
            Vector3[] vertices = mesh.vertices;
            for (int i = 0; i < vertices.Length; i++) {
                vertices[i] = new Vector3(-vertices[i].x, vertices[i].y, vertices[i].z);
            }
            mesh.vertices = vertices;
            mesh.triangles = mesh.triangles.Reverse().ToArray();
        }
    }

    // 变形函数：给定正方形中的某一点，计算该点在四边形中的位置，主要用到了等比例法
    public void DeformModule(Mesh mesh, SubQuad_Cube subQuad_Cube) {
        Vector3[] vertices = mesh.vertices;
        SubQuad subQuad = subQuad_Cube.subQuad;
        for (int i = 0; i < vertices.Length; i++) {
            Vector3 ad_x = Vector3.Lerp(subQuad.a.currentPosition, subQuad.d.currentPosition, (vertices[i].x + 0.5f));
            Vector3 bc_x = Vector3.Lerp(subQuad.b.currentPosition, subQuad.c.currentPosition, (vertices[i].x + 0.5f));
            vertices[i] = Vector3.Lerp(ad_x, bc_x, (vertices[i].z + 0.5f)) + Vector3.up * vertices[i].y * Grid.cellHeight - subQuad.GetCenterPosition();
        }

        mesh.vertices = vertices;
    }

    public void UpdateModule(Module module) {
        this.module.GetComponent<MeshFilter>().mesh = module.mesh;
        FlipModule(this.module.GetComponent<MeshFilter>().mesh, module.flip);
        RotateMoule(this.module.GetComponent<MeshFilter>().mesh, module.rotation);
        DeformModule(this.module.GetComponent<MeshFilter>().mesh, subQuad_Cube);

        // 这里不应该对整个transform做旋转，而是应该对mesh做旋转
        // transform.rotation *= Quaternion.AngleAxis(180, Vector3.up);

        // 为什么要对mesh再旋转180度，可能是因为模型的坐标系和unity的坐标系不一样，也可能是blender模型面片导出有误。改正：在Blender中旋转一下之后，就好了，下面的代码就可以注释掉了
        // MeshRotateY_180(this.module.GetComponent<MeshFilter>().mesh);

        this.module.GetComponent<MeshRenderer>().material = material;

        this.module.GetComponent<MeshFilter>().mesh.RecalculateNormals();
        this.module.GetComponent<MeshFilter>().mesh.RecalculateBounds();
    }

    public void Collapse(int i) {
        possibleModules = new List<Module>() { possibleModules[i] };
        reset = false;
    }

    public void MeshRotateY_180(Mesh mesh) {
        // 对mesh做旋转180度
        Vector3[] vertices = mesh.vertices;
        for (int i = 0; i < vertices.Length; i++) {
            vertices[i] = Quaternion.AngleAxis(180, Vector3.up) * vertices[i];
        }
        mesh.vertices = vertices;
    }
}
