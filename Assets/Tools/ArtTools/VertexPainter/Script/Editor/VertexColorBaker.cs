using UnityEngine;
using UnityEditor;
using System.Collections;
using System.Collections.Generic;
using System.Linq;


public class BakeVertexColor : EditorWindow
{
	[MenuItem("美术/Vertex Color Baker",false,1003)]
	static void Init()
	{
		EditorWindow.GetWindow<BakeVertexColor>(true, "Bake Vertex Streams", true);
	}

	void OnEnable()
	{
		Undo.undoRedoPerformed += UndoRedoPerformed;
		autoRepaintOnSceneChange = true;
		OnSelectionChange();
	}

	void OnFocus()
	{
		OnSelectionChange();
	}

	void OnDisable()
	{
		Undo.undoRedoPerformed -= UndoRedoPerformed;
	}

	private List<PaintingData> m_VertexStreams = new List<PaintingData>();
	private Vector2 scroll = Vector2.zero;

	private GUIContent m_BatchNewMesh = new GUIContent("Create New\nComposite Mesh", "Create a new mesh for each selected mesh, automatically prefixing the built meshes with z_ and index.  This is useful in situations where you have used Additional Vertex Streams to paint a single mesh source many times and would like to ensure that all meshes remain unique.");

	void OnGUI()
	{
		GUILayout.BeginHorizontal();

			GUILayout.BeginVertical();
				GUILayout.Label("Selected", EditorStyles.boldLabel);

				scroll = EditorGUILayout.BeginScrollView(scroll, false, true);

				foreach(PaintingData vertexStream in m_VertexStreams)
				{
					if(vertexStream != null)
						GUILayout.Label(string.Format("{0}", vertexStream.gameObject.name));
				}

				EditorGUILayout.EndScrollView();
			GUILayout.EndVertical();

			GUILayout.BeginVertical();
				GUILayout.Label("Bake Options", EditorStyles.boldLabel);

				GUI.enabled = m_VertexStreams.Count == 1;

        if (GUILayout.Button("Apply to\nCurrent Mesh"))
        {
            if (EditorUtility.DisplayDialog("Apply Vertex Streams to Mesh", "This action is not undo-able, are you sure you want to continue?", "Yes", "Cancel"))
            {
                foreach (var stream in m_VertexStreams)
                    CreateComposite(stream, true);
            }

            m_VertexStreams.Clear();
        }

        if (GUILayout.Button("Create New\nComposite Mesh"))
				{
					foreach(var stream in m_VertexStreams)
						CreateComposite(stream, false);

					m_VertexStreams.Clear();
				}

				GUI.enabled = m_VertexStreams.Count > 0;

				GUILayout.Label("Batch Options", EditorStyles.boldLabel);

				if(GUILayout.Button(m_BatchNewMesh))
				{
					string path = EditorUtility.OpenFolderPanel("Save Vertex Stream Meshes", "Assets", "");

					for(int i = 0; i < m_VertexStreams.Count; i++)
					{
						path = path.Replace(Application.dataPath, "Assets");

						if(m_VertexStreams[i] == null || m_VertexStreams[i].savedColors == null)
							continue;

						CreateComposite(m_VertexStreams[i], false, string.Format("{0}/{1}.asset", path, m_VertexStreams[i].gameObject.name));
					}

					m_VertexStreams.Clear();
				}

			GUILayout.EndVertical();

		GUILayout.EndHorizontal();
	}

	void OnSelectionChange()
	{
		m_VertexStreams = Selection.transforms.SelectMany(x => x.GetComponentsInChildren<PaintingData>()).ToList();
		Repaint();
	}

	void UndoRedoPerformed()
	{
		foreach(Mesh m in Selection.transforms.SelectMany(x => x.GetComponentsInChildren<MeshFilter>()).Select(y => y.sharedMesh))
		{
			if(m != null)
				m.UploadMeshData(false);
		}
	}

	void CreateComposite(PaintingData vertexStream, bool applyToCurrent, string path = null)
	{
		GameObject go = vertexStream.gameObject;

		Mesh source = GetMesh(go);
        //Mesh stream = vertexStream.m_AdditionalVertexStreamMesh;
        Mesh stream = vertexStream.GetModifierMesh();

		if(source == null || stream == null)
		{
			Debug.LogWarning("Mesh filter or vertex stream mesh is null, cannot continue.");
			return;
		}

		if(applyToCurrent)
		{
			CreateCompositeMesh(source, stream, source);

			MeshRenderer renderer = go.GetComponent<MeshRenderer>();

			if(renderer != null)
				renderer.additionalVertexStreams = null;

			GameObject.DestroyImmediate(vertexStream);
		}
		else
		{
			Mesh composite = new Mesh();
			CreateCompositeMesh(source, stream, composite);

			if( string.IsNullOrEmpty(path) )
			{
				SaveMeshAsset(composite, go.GetComponent<MeshFilter>(), go.GetComponent<SkinnedMeshRenderer>());
			}
			else
			{
				AssetDatabase.CreateAsset(composite, path);

				MeshFilter mf = go.GetComponent<MeshFilter>();
					
				SkinnedMeshRenderer smr = go.GetComponent<SkinnedMeshRenderer>();

				if(mf != null)
					mf.sharedMesh = composite;
				else if(smr != null)
					smr.sharedMesh = composite;
			}


			Undo.DestroyObjectImmediate(vertexStream);
		}
        AssetDatabase.DeleteAsset(AssetDatabase.GetAssetPath(vertexStream.savedColors));
	}

	void CreateCompositeMesh(Mesh source, Mesh vertexStream, Mesh composite)
	{
		int vertexCount = source.vertexCount;
		bool isNewMesh = composite.vertexCount != vertexCount;

		composite.name = source.name;

		composite.vertices = vertexStream.vertices != null && vertexStream.vertices.Length == vertexCount ?
			vertexStream.vertices :
			source.vertices;

		composite.normals = vertexStream.normals != null  && vertexStream.normals.Length == vertexCount ?
			vertexStream.normals :
			source.normals;

		composite.tangents = vertexStream.tangents != null && vertexStream.tangents.Length == vertexCount ?
			vertexStream.tangents :
			source.tangents;

		composite.boneWeights = vertexStream.boneWeights != null && vertexStream.boneWeights.Length == vertexCount ?
			vertexStream.boneWeights :
			source.boneWeights;

		composite.colors32 = vertexStream.colors32 != null && vertexStream.colors32.Length == vertexCount ?
			vertexStream.colors32 :
			source.colors32;

		composite.bindposes = vertexStream.bindposes != null && vertexStream.bindposes.Length == vertexCount ?
			vertexStream.bindposes :
			source.bindposes;
	
		List<Vector4> uvs = new List<Vector4>();

		vertexStream.GetUVs(0, uvs);
		if(uvs == null || uvs.Count != vertexCount)
			source.GetUVs(0, uvs);
		composite.SetUVs(0, uvs);

		vertexStream.GetUVs(1, uvs);
		if(uvs == null || uvs.Count != vertexCount)
			source.GetUVs(1, uvs);
		composite.SetUVs(1, uvs);

		vertexStream.GetUVs(2, uvs);
		if(uvs == null || uvs.Count != vertexCount)
			source.GetUVs(2, uvs);
		composite.SetUVs(2, uvs);

		vertexStream.GetUVs(3, uvs);
		if(uvs == null || uvs.Count != vertexCount)
			source.GetUVs(3, uvs);
		composite.SetUVs(3, uvs);

		if(isNewMesh)
		{
			composite.subMeshCount = source.subMeshCount;

			for(int i = 0; i < source.subMeshCount; i++)
				composite.SetIndices(source.GetIndices(i), source.GetTopology(i), i);
		}
	}

    private Mesh GetMesh(GameObject gameObject)
    {
        MeshFilter mf = gameObject.GetComponent<MeshFilter>();

        if (mf != null && mf.sharedMesh != null)
            return mf.sharedMesh;

        SkinnedMeshRenderer smr = gameObject.GetComponent<SkinnedMeshRenderer>();

        if (smr != null && smr.sharedMesh != null)
            return smr.sharedMesh;
        else
            return null;
    }
    const int DIALOG_OK = 0;
    const int DIALOG_CANCEL = 1;
    const int DIALOG_ALT = 2;
    const string DO_NOT_SAVE = "DO_NOT_SAVE";

    public bool SaveMeshAsset(Mesh mesh, MeshFilter meshFilter = null, SkinnedMeshRenderer skinnedMeshRenderer = null)
    {
        string save_path = "DO_NOT_SAVE";

        string guid = null;
        z_ModelSource source = GetMeshGUID(mesh, ref guid);

        switch (source)
        {
            case z_ModelSource.Asset:

                int saveChanges = EditorUtility.DisplayDialogComplex(
                    "Save Changes",
                    "Save changes to edited mesh?",
                    "Save",             // DIALOG_OK
                    "Cancel",           // DIALOG_CANCEL
                    "Save As");         // DIALOG_ALT

                if (saveChanges == DIALOG_OK)
                    save_path = AssetDatabase.GetAssetPath(mesh);
                else if (saveChanges == DIALOG_ALT)
                    save_path = EditorUtility.SaveFilePanelInProject("Save Mesh As", mesh.name + ".asset", "asset", "Save edited mesh to");
                else
                    return false;

                break;

            case z_ModelSource.Imported:
            case z_ModelSource.Scene:
            default:
                // @todo make sure path is in Assets/
                save_path = EditorUtility.SaveFilePanelInProject("Save Mesh As", mesh.name + ".asset", "asset", "Save edited mesh to");
                break;
        }

        if (!save_path.Equals(DO_NOT_SAVE) && !string.IsNullOrEmpty(save_path))
        {
            Object existing = AssetDatabase.LoadMainAssetAtPath(save_path);

            if (existing != null && existing is Mesh)
            {
                // save over an existing mesh asset
                Copy((Mesh)existing, mesh);
                GameObject.DestroyImmediate(mesh);
            }
            else
            {
                AssetDatabase.CreateAsset(mesh, save_path);
            }

            AssetDatabase.Refresh();

            if (meshFilter != null)
                meshFilter.sharedMesh = (Mesh)AssetDatabase.LoadAssetAtPath(save_path, typeof(Mesh));
            else if (skinnedMeshRenderer != null)
                skinnedMeshRenderer.sharedMesh = (Mesh)AssetDatabase.LoadAssetAtPath(save_path, typeof(Mesh));

            return true;
        }

        // Save was canceled
        return false;
    }
    public z_ModelSource GetMeshGUID(Mesh mesh, ref string guid)
    {
        string path = AssetDatabase.GetAssetPath(mesh);

        if (path != "")
        {
            AssetImporter assetImporter = AssetImporter.GetAtPath(path);

            if (assetImporter != null)
            {
                // Only imported model (e.g. FBX) assets use the ModelImporter,
                // where a saved asset will have an AssetImporter but *not* ModelImporter.
                // A procedural mesh (one only existing in a scene) will not have any.
                if (assetImporter is ModelImporter)
                {
                    guid = AssetDatabase.AssetPathToGUID(path);
                    return z_ModelSource.Imported;
                }
                else
                {
                    guid = AssetDatabase.AssetPathToGUID(path);
                    return z_ModelSource.Asset;
                }
            }
            else
            {
                return z_ModelSource.Scene;
            }
        }

        return z_ModelSource.Scene;
    }

    public void Copy(Mesh dest, Mesh src)
    {
        dest.Clear();
        dest.vertices = src.vertices;

        List<Vector4> uvs = new List<Vector4>();

        src.GetUVs(0, uvs); dest.SetUVs(0, uvs);
        src.GetUVs(1, uvs); dest.SetUVs(1, uvs);
        src.GetUVs(2, uvs); dest.SetUVs(2, uvs);
        src.GetUVs(3, uvs); dest.SetUVs(3, uvs);

        dest.normals = src.normals;
        dest.tangents = src.tangents;
        dest.boneWeights = src.boneWeights;
        dest.colors = src.colors;
        dest.colors32 = src.colors32;
        dest.bindposes = src.bindposes;

        dest.subMeshCount = src.subMeshCount;

        for (int i = 0; i < src.subMeshCount; i++)
            dest.SetIndices(src.GetIndices(i), src.GetTopology(i), i);

        dest.name = src.name + "c";
    }
}

public enum z_ModelSource
{
    Imported = 0x0,
    Asset = 0x1,
    Scene = 0x2,
    AdditionalVertexStreams = 0x3
}