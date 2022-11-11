using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CustomEditor(typeof(P3dCoordCopier))]
	public class P3dCoordCopier_Editor : P3dEditor<P3dCoordCopier>
	{
		protected override void OnInspector()
		{
			EditorGUILayout.HelpBox("This tool will copy the UV1 data (e.g. lightmap UVs) into UV0, so you can use it with normal painting. The fixed mesh will be placed as a child of this tool in your Project window. To use the fixed mesh, drag and drop it into your MeshFilter or SkinnedMeshRenderer.", MessageType.Info);

			Separator();

			BeginError(Any(t => t.Source == null));
				DrawDefault("source", "The original mesh whose UV data you want to copy.");
			EndError();

			Separator();

			if (Button("Generate") == true)
			{
				Each(t => t.Generate());
			}
		}
	}
}
#endif

namespace PaintIn3D
{
	[ExecuteInEditMode]
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dCoordCopier")]
	public class P3dCoordCopier : ScriptableObject
	{
		/// <summary>The original mesh whose UV seams you want to fix.</summary>
		public Mesh Source { set { source = value; } get { return source; } } [SerializeField] private Mesh source;

		[SerializeField]
		private Mesh mesh;

		[System.NonSerialized]
		private static List<BoneWeight> boneWeights = new List<BoneWeight>();

		[System.NonSerialized]
		private static List<Color32> colors = new List<Color32>();

		[System.NonSerialized]
		private static List<Vector3> positions = new List<Vector3>();

		[System.NonSerialized]
		private static List<Vector3> normals = new List<Vector3>();

		[System.NonSerialized]
		private static List<Vector4> tangents = new List<Vector4>();

		[System.NonSerialized]
		private static List<Vector4> coords0 = new List<Vector4>();

		[System.NonSerialized]
		private static List<Vector4> coords1 = new List<Vector4>();

		[System.NonSerialized]
		private static List<Vector4> coords2 = new List<Vector4>();

		[System.NonSerialized]
		private static List<Vector4> coords3 = new List<Vector4>();

		[System.NonSerialized]
		private static List<int> indices = new List<int>();

#if UNITY_EDITOR
		[MenuItem("CONTEXT/Mesh/Coord Copier (Paint in 3D)")]
		public static void Create(MenuCommand menuCommand)
		{
			var mesh = menuCommand.context as Mesh;

			if (mesh != null)
			{
				var path = AssetDatabase.GetAssetPath(mesh);

				if (string.IsNullOrEmpty(path) == false)
				{
					path = System.IO.Path.GetDirectoryName(path);
				}
				else
				{
					path = "Assets";
				}

				path += "/Coord Copier (" + mesh.name + ").asset";

				var instance = CreateInstance<P3dCoordCopier>();

				instance.source = mesh;

				ProjectWindowUtil.CreateAsset(instance, path);
			}
		}
#endif

		public void Generate()
		{
			if (source != null)
			{
				if (mesh == null)
				{
					mesh = new Mesh();
				}

				mesh.Clear(false);
				mesh.name = source.name + " (Copied Coords)";

				mesh.bindposes = source.bindposes;
				mesh.bounds = source.bounds;
				mesh.subMeshCount = source.subMeshCount;

				source.GetBoneWeights(boneWeights);
				source.GetColors(colors);
				source.GetNormals(normals);
				source.GetTangents(tangents);
				source.GetUVs(0, coords0);
				source.GetUVs(1, coords1);
				source.GetUVs(2, coords2);
				source.GetUVs(3, coords3);
				source.GetVertices(positions);

				mesh.SetVertices(positions);

				for (var i = 0; i < source.subMeshCount; i++)
				{
					source.GetTriangles(indices, i);

					mesh.SetTriangles(indices, i);
				}
				
				mesh.boneWeights = boneWeights.ToArray();
				mesh.SetColors(colors);
				mesh.SetNormals(normals);
				mesh.SetTangents(tangents);
				//mesh.SetUVs(0, coords0);
				mesh.SetUVs(0, coords1);
				mesh.SetUVs(1, coords1);
				mesh.SetUVs(2, coords2);
				mesh.SetUVs(3, coords3);

#if UNITY_EDITOR
				if (P3dHelper.IsAsset(this) == true)
				{
					var assets = AssetDatabase.LoadAllAssetsAtPath(AssetDatabase.GetAssetPath(this));

					for (var i = 0; i < assets.Length; i++)
					{
						var assetMesh = assets[i] as Mesh;

						if (assetMesh != null && assetMesh != mesh)
						{
							DestroyImmediate(assetMesh, true);
						}
					}

					if (P3dHelper.IsAsset(mesh) == false)
					{
						AssetDatabase.AddObjectToAsset(mesh, this);
					}
				}
#endif
			}

#if UNITY_EDITOR
			if (P3dHelper.IsAsset(this) == true)
			{
				P3dHelper.ReimportAsset(this);
			}
#endif
		}

		protected virtual void OnDestroy()
		{
			P3dHelper.Destroy(mesh);
		}
	}
}