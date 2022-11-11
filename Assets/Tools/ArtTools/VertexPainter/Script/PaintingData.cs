using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class PaintingData : MonoBehaviour
{
    [HideInInspector]
    [SerializeField]
    private Color[] _colors;

    /*[HideInInspector]
    [SerializeField]
    private Vector3[] _positions;*/
	[SerializeField]
	public MeshVertexColor savedColors;

    public Color[] colors
    {
        get
        {
            return _colors;
        }
        set
        {
            enforcedColorChannels = (!(_colors == null || (value != null && _colors.Length != value.Length)));
			if (savedColors != null)
			savedColors._colors = value;
            _colors = value;
            Apply();
        }
    }

    //public Vector3[] positions { get { return _positions; } set { _positions = value; Apply(); } }

#if UNITY_EDITOR
    [HideInInspector]
    public Material[] originalMaterial;
    public static Material vertexShaderMat;

    public void SetColor(Color c, int count) { _colors = new Color[count]; for (int i = 0; i < count; ++i) { _colors[i] = c; } Apply(); }

    void Awake()
    {
        MeshRenderer mr = GetComponent<MeshRenderer>();
        if (mr != null)
        {
            if (mr.sharedMaterials != null && mr.sharedMaterial == vertexShaderMat && originalMaterial != null
               && originalMaterial.Length == mr.sharedMaterials.Length && originalMaterial.Length > 1)
            {
                Material[] mats = new Material[mr.sharedMaterials.Length];
                for (int i = 0; i < mr.sharedMaterials.Length; ++i)
                {
                    if (originalMaterial[i] != null)
                    {
                        mats[i] = originalMaterial[i];
                    }
                }
                mr.sharedMaterials = mats;
            }
            else if (originalMaterial != null && originalMaterial.Length > 0)
            {
                if (originalMaterial[0] != null)
                {
                    mr.sharedMaterial = originalMaterial[0];
                }
            }
        }
    }
#endif

    void Start()
    {
		if (savedColors != null)
			colors = savedColors._colors;
        Apply();
    }

    void OnDestroy()
    {
        if (!Application.isPlaying)
        {
            MeshRenderer mr = GetComponent<MeshRenderer>();
            if (mr != null)
                mr.additionalVertexStreams = null;
        }
    }

    private Mesh meshStream;

	public Mesh Apply(bool markNoLongerReadable = true)
	{
		SkinnedMeshRenderer skinMr = GetComponent<SkinnedMeshRenderer>();
		if (skinMr != null)
		{
			Mesh stream = ApplyMeshData(skinMr.sharedMesh, true);
			skinMr.sharedMesh.SetColors(stream.colors.ToList());
			return stream;
		}
		else
		{
			MeshRenderer mr = GetComponent<MeshRenderer>();
			MeshFilter mf = GetComponent<MeshFilter>();
			if (mr != null && mf != null && mf.sharedMesh != null)
			{
				Mesh stream = ApplyMeshData(mf.sharedMesh, false);
				mr.additionalVertexStreams = stream;
				return stream;
			}
		}
		return null;
	}
	public Mesh ApplyMeshData(Mesh mesh, bool isSkinMesh, bool markNoLongerReadable = false)
	{
		int vertexCount = mesh.vertexCount;
		Mesh stream = meshStream;
		if (stream == null || vertexCount != stream.vertexCount)
		{
			if (stream != null)
			{
				DestroyImmediate(stream);
			}
			stream = new Mesh();
			stream.vertices = new Vector3[mesh.vertexCount];
			stream.vertices = mesh.vertices;
			stream.MarkDynamic();
			stream.triangles = mesh.triangles;
			meshStream = stream;

			stream.hideFlags = HideFlags.HideAndDontSave;
		}
		//if (_positions != null && _positions.Length == vertexCount) { stream.vertices = _positions; }
		if (_colors != null && _colors.Length == vertexCount) { stream.colors = _colors; } else { stream.colors = null; }

		//EnforceOriginalMeshHasColors(stream);

		if (!Application.isPlaying || Application.isEditor)
		{
			markNoLongerReadable = false;
		}
		stream.UploadMeshData(markNoLongerReadable);
		return stream;
	}
#if UNITY_EDITOR
    public Mesh GetModifierMesh() { return meshStream; }
    private MeshRenderer meshRend = null;
	private SkinnedMeshRenderer skinMeshRend = null;
    void Update()
    {
		if (skinMeshRend == null)
		{
			skinMeshRend = GetComponent<SkinnedMeshRenderer>();
		}
		else
		{
			skinMeshRend.sharedMesh.SetColors(meshStream.colors.ToList());
		}
		if (meshRend == null)
		{
			meshRend = GetComponent<MeshRenderer>();
		}
		else
		{
			meshRend.additionalVertexStreams = meshStream;
		}
    }
#endif

    bool enforcedColorChannels = false;
    void EnforceOriginalMeshHasColors(Mesh stream)
    {
        if (enforcedColorChannels == true)
            return;
        enforcedColorChannels = true;
		SkinnedMeshRenderer skinMr = GetComponent<SkinnedMeshRenderer>();
		if (skinMr != null)
		{
			Color[] origColors = skinMr.sharedMesh.colors;
			if (stream != null && stream.colors.Length > 0 && (origColors == null || origColors.Length == 0))
			{
				skinMr.sharedMesh.colors = stream.colors;
			}
		}
		else
		{
			MeshFilter mf = GetComponent<MeshFilter>();
			Color[] origColors = mf.sharedMesh.colors;
			if (stream != null && stream.colors.Length > 0 && (origColors == null || origColors.Length == 0))
			{
				mf.sharedMesh.colors = stream.colors;
			}
		}
    }
}