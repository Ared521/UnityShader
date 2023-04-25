using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundCollider : MonoBehaviour
{
    public void CreateCollider(Grid grid) {
        foreach (SubQuad subQuad in grid.subQuads) {
            Vector3[] meshVertices = new Vector3[]{ subQuad.a.currentPosition, subQuad.b.currentPosition, subQuad.c.currentPosition, subQuad.d.currentPosition };

            int[] meshTriangles = new int[] { 0, 1, 2, 
                                              0, 2, 3 };

            Mesh mesh = new Mesh();
            mesh.vertices = meshVertices;
            mesh.triangles = meshTriangles;
            GameObject groundCollider_Quad = new GameObject("QuadCollider_" + grid.subQuads.IndexOf(subQuad), typeof(MeshCollider), typeof(GroundCollider_Quad));
            groundCollider_Quad.transform.SetParent(transform);
            groundCollider_Quad.transform.localPosition = Vector3.up * Grid.cellHeight * 0.5f;
            groundCollider_Quad.GetComponent<MeshCollider>().sharedMesh = mesh;
            groundCollider_Quad.GetComponent<GroundCollider_Quad>().subQuad = subQuad;
            groundCollider_Quad.layer = LayerMask.NameToLayer("GroundCollider");
        }
    }
}

public class GroundCollider_Quad : MonoBehaviour {
    public SubQuad subQuad;
}
