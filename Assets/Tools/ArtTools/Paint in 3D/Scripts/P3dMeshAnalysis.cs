#if UNITY_EDITOR
using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public partial class P3dMeshAnalysis : P3dEditorWindow
	{
		private Mesh mesh;

		private int coord;

		private int submesh;

		private int mode;

		private Vector3 rotation;

		private bool ready;

		private int triangleCount;

		private int invalidCount;

		private string[] submeshNames = new string[0];

		private List<int> indices = new List<int>();

		private List<Vector3> positions = new List<Vector3>();

		private List<Vector2> coords = new List<Vector2>();

		private Vector3[] arrayA;

		private List<Vector3> listA = new List<Vector3>();

		private Vector3[] arrayB;

		private List<Vector3> listB = new List<Vector3>();

		private List<float> ratioList = new List<float>();

#if UNITY_EDITOR
		[MenuItem("CONTEXT/Mesh/Analyze Mesh (Paint in 3D)")]
		public static void Create(MenuCommand menuCommand)
		{
			var mesh = menuCommand.context as Mesh;

			if (mesh != null)
			{
				OpenWith(mesh);
			}
		}
#endif

		public static void OpenWith(GameObject gameObject)
		{
			var meshFilter = gameObject.GetComponent<MeshFilter>();

			if (meshFilter != null)
			{
				OpenWith(meshFilter.sharedMesh);
			}
			else
			{
				var skinnedMeshRenderer = gameObject.GetComponent<SkinnedMeshRenderer>();

				if (skinnedMeshRenderer != null)
				{
					OpenWith(skinnedMeshRenderer.sharedMesh);
				}
			}
		}

		public static void OpenWith(Mesh mesh)
		{
			var window = GetWindow<P3dMeshAnalysis>("Mesh Analysis", true);

			window.mesh  = mesh;
			window.ready = false;

			window.Analyze();
		}

		protected override void OnInspector()
		{
			if (mesh != null)
			{
				EditorGUI.BeginDisabledGroup(true);
					EditorGUILayout.ObjectField("Mesh", mesh, typeof(Mesh), false);
				EditorGUI.EndDisabledGroup();

				if (mesh.subMeshCount != submeshNames.Length)
				{
					var submeshNamesList = new List<string>();

					for (var i = 0; i < mesh.subMeshCount; i++)
					{
						submeshNamesList.Add(i.ToString());
					}

					submeshNames = submeshNamesList.ToArray();
				}

				EditorGUILayout.Separator();
				
				var newSubmesh  = EditorGUILayout.Popup("Submesh", submesh, submeshNames);
				var newCoord    = EditorGUILayout.Popup("Coord", coord, new string[] { "UV0", "UV1", "UV2", "UV3" });
				var newMode     = EditorGUILayout.Popup("Mode", mode, new string[] { "Texcoord", "Triangles" });
				var newRotation = EditorGUILayout.Vector3Field("Rotation", rotation);

				EditorGUILayout.Separator();

				EditorGUILayout.LabelField("Triangles", EditorStyles.boldLabel);
				EditorGUI.BeginDisabledGroup(true);
					EditorGUILayout.IntField("Total", triangleCount);
					EditorGUILayout.IntField("With No UV", invalidCount);
				EditorGUI.EndDisabledGroup();

				if (coord != newCoord || newSubmesh != submesh || newMode != mode || newRotation != rotation || ready == false)
				{
					ready         = true;
					coord         = newCoord;
					submesh       = newSubmesh;
					mode          = newMode;
					rotation      = newRotation;
					
					listA.Clear();
					listB.Clear();
					ratioList.Clear();
					mesh.GetTriangles(indices, submesh);
					mesh.GetVertices(positions);
					mesh.GetUVs(coord, coords);

					triangleCount = indices.Count / 3;
					invalidCount  = 0;

					if (coords.Count > 0)
					{
						var rot  = Quaternion.Euler(rotation);
						var off  = -mesh.bounds.center;
						var mul  = P3dHelper.Reciprocal(mesh.bounds.size.magnitude);
						var half = Vector3.one * 0.5f;

						for (var i = 0; i < indices.Count; i += 3)
						{
							var positionA = positions[indices[i + 0]];
							var positionB = positions[indices[i + 1]];
							var positionC = positions[indices[i + 2]];
							var coordA    = coords[indices[i + 0]];
							var coordB    = coords[indices[i + 1]];
							var coordC    = coords[indices[i + 2]];
							var area      = Vector3.Cross(coordA - coordB, coordA - coordC).sqrMagnitude;
							var invalid   = area <= float.Epsilon;

							if (invalid == true)
							{
								invalidCount++;
							}

							if (mode == 0) // Texcoord
							{
								listA.Add(coordA); listA.Add(coordB);
								listA.Add(coordB); listA.Add(coordC);
								listA.Add(coordC); listA.Add(coordA);
							}

							if (mode == 1) // Triangles
							{
								positionA = half + rot * (off + positionA) * mul;
								positionB = half + rot * (off + positionB) * mul;
								positionC = half + rot * (off + positionC) * mul;

								positionA.z = positionB.z = positionC.z = 0.0f;

								listA.Add(positionA); listA.Add(positionB);
								listA.Add(positionB); listA.Add(positionC);
								listA.Add(positionC); listA.Add(positionA);

								if (invalid == true)
								{
									listB.Add(positionA); listB.Add(positionB);
									listB.Add(positionB); listB.Add(positionC);
									listB.Add(positionC); listB.Add(positionA);
								}
							}
						}
					}

					arrayA = listA.ToArray();
					arrayB = listB.ToArray();
				}

				var rect = P3dHelper.Reserve(position.height - 186.0f); GUI.Box(rect, ""); rect.min += Vector2.one * 3.0f; rect.max -= Vector2.one * 3.0f;
				var pos  = rect.min;
				var siz  = rect.size;

				Handles.BeginGUI();
					if (listA.Count > 0)
					{
						for (var i = listA.Count - 1; i >= 0; i--)
						{
							var coord = listA[i];

							coord.x = pos.x + siz.x * coord.x;
							coord.y = pos.y + siz.y * (1.0f - coord.y);

							arrayA[i] = coord;
						}

						Handles.DrawLines(arrayA);

						for (var i = listB.Count - 1; i >= 0; i--)
						{
							var coord = listB[i];

							coord.x = pos.x + siz.x * coord.x;
							coord.y = pos.y + siz.y * (1.0f - coord.y);

							arrayB[i] = coord;
						}

						Handles.color = Color.red;
						Handles.DrawLines(arrayB);
					}
				Handles.EndGUI();
			}
			else
			{
				EditorGUILayout.HelpBox("No Mesh Selected.\nTo select a mesh, click Analyze Mesh from the P3dPaintable component, or from the Mesh inspector context menu (gear icon at top right).", MessageType.Info);
			}
		}

		private void Analyze()
		{
			
		}
	}
}
#endif