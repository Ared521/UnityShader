using System;
using System.Collections.Generic;
using UnityEngine;

public class PaintingObject
{
	public SkinnedMeshRenderer skinMeshRenderer;
	public GameObject tempGo;
    public MeshFilter meshFilter;
    public Renderer renderer;
    public PaintingData _stream;

    public List<int>[] vertexConnections;
    public Vector3[] verts;
    public Vector3 GetPosition(int i)
    {
        return verts[i];
    }

    public bool HasStream() { return _stream != null; }
    public bool HasData()
    {
        if (_stream == null)
            return false;

        int vertexCount = verts.Length;
        bool hasColors = (stream.colors != null && stream.colors.Length == vertexCount);

        return (hasColors);
    }

    public PaintingData stream
    {
        get
        {
            if (_stream == null)
            {
                if (meshFilter == null)
                {
                    return null;
                }
                _stream = meshFilter.gameObject.GetComponent<PaintingData>();
                if (_stream == null)
                {
                    _stream = meshFilter.gameObject.AddComponent<PaintingData>();
                }
                else
                {
                    _stream.Apply();
                }
            }
            return _stream;
        }

    }

    public void EnforceStream()
    {
        if (_stream == null && renderer != null && meshFilter != null)
        {
            _stream = meshFilter.gameObject.AddComponent<PaintingData>();
        }
    }

    public void InitMeshConnections()
    {
        int vertCount = meshFilter.sharedMesh.vertexCount;
        vertexConnections = new List<int>[vertCount];
        for (int i = 0; i < vertexConnections.Length; ++i)
        {
            vertexConnections[i] = new List<int>();
        }
    }

    public PaintingObject(MeshFilter mf, Renderer r)
    {
        meshFilter = mf;
        renderer = r;
        _stream = r.gameObject.GetComponent<PaintingData>();
        verts = mf.sharedMesh.vertices;
        InitMeshConnections();
    }
	public PaintingObject(SkinnedMeshRenderer skinMr)
	{
		skinMeshRenderer = skinMr;
		var bakeMesh = new Mesh();
		skinMr.BakeMesh(bakeMesh);
		skinMr.enabled = false;

		tempGo = new GameObject(skinMr.gameObject.name, typeof(MeshRenderer), typeof(MeshFilter));
		tempGo.hideFlags = HideFlags.HideAndDontSave;
		tempGo.transform.position = skinMr.transform.position;
		tempGo.transform.rotation = skinMr.transform.rotation;

		var mr = tempGo.GetComponent<MeshRenderer>();
		var mf = tempGo.GetComponent<MeshFilter>();
		mr.sharedMaterials = skinMr.sharedMaterials;
		mf.sharedMesh = bakeMesh;

		meshFilter = mf;
		renderer = mr;
		_stream = mf.gameObject.GetComponent<PaintingData>();
		verts = mf.sharedMesh.vertices;
		InitMeshConnections();
	}
	public void RevertMesh()
	{ 
		if(skinMeshRenderer != null)
		skinMeshRenderer.enabled = true;
		if(tempGo != null)
		GameObject.DestroyImmediate(tempGo);
	}
}
