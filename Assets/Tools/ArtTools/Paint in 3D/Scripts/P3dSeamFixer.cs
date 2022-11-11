using UnityEngine;
using UnityEngine.UI;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CustomEditor(typeof(P3dSeamFixer))]
	public class P3dSeamFixer_Editor : P3dEditor<P3dSeamFixer>
	{
		protected override void OnInspector()
		{
			EditorGUILayout.HelpBox("This tool will convert a normal mesh into a mesh with UV seams suitable for painting. The fixed mesh will be placed as a child of this tool in your Project window. To use the fixed mesh, drag and drop it into your MeshFilter or SkinnedMeshRenderer.", MessageType.Info);

			Separator();

			BeginError(Any(t => t.Source == null));
				DrawDefault("source", "The original mesh whose UV seams you want to fix.");
			EndError();
			DrawDefault("channel", "The UV channel whose seams will be fixed.");
			BeginError(Any(t => t.Threshold <= 0.0f));
				DrawDefault("threshold", "The threshold below which vertex UV coordinates will be snapped.");
			EndError();
			BeginError(Any(t => t.Border <= 0.0f));
				DrawDefault("border", "The thickness of the UV borders in the fixed mesh.");
			EndError();

			Separator();

			P3dSeamFixer.DebugScale = EditorGUILayout.FloatField("Debug Scale", P3dSeamFixer.DebugScale);

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
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dSeamFixer")]
	public class P3dSeamFixer : ScriptableObject
	{
		class Edge
		{
			public bool    Used;
			public int     IndexA;
			public int     IndexB;
			public Vector2 CoordA;
			public Vector2 CoordB;
		}

		struct Point
		{
			public int     Index;
			public Vector2 Coord;
		}

		/// <summary>If this is above 0 then Debug.Lines will be output during generation.</summary>
		public static float DebugScale;

		/// <summary>The original mesh whose UV seams you want to fix.</summary>
		public Mesh Source { set { source = value; } get { return source; } } [SerializeField] private Mesh source;

		/// <summary>The UV channel whose seams will be fixed.</summary>
		public P3dChannel Channel { set { channel = value; } get { return channel; } } [SerializeField] private P3dChannel channel;

		/// <summary>The threshold below which vertex UV coordinates will be snapped.</summary>
		public float Threshold { set { threshold = value; } get { return threshold; } } [SerializeField] private float threshold = 0.000001f;

		/// <summary>The thickness of the UV borders in the fixed mesh.</summary>
		public float Border { set { border = value; } get { return border; } } [SerializeField] private float border = 0.005f;

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

		[System.NonSerialized]
		private static List<Edge> edges = new List<Edge>();

		[System.NonSerialized]
		private static List<Point> points = new List<Point>();

		[System.NonSerialized]
		private static float areaThreshold;

		[System.NonSerialized]
		private static float coordThreshold;

		[System.NonSerialized]
		private static Vector2 startCoord;

#if UNITY_EDITOR
		[MenuItem("CONTEXT/Mesh/Fix Seams (Paint in 3D)")]
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

				path += "/Seam Fixer (" + mesh.name + ").asset";

				var instance = CreateInstance<P3dSeamFixer>();

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
				mesh.name = source.name + " (Fixed Seams)";

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

				DoGenerate();
				
				mesh.boneWeights = boneWeights.ToArray();
				mesh.SetColors(colors);
				mesh.SetNormals(normals);
				mesh.SetTangents(tangents);
				mesh.SetUVs(0, coords0);
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

		private void DoGenerate()
		{
			areaThreshold  = threshold * threshold;
			coordThreshold = threshold * threshold;

			for (var i = 0; i < source.subMeshCount; i++)
			{
				edges.Clear();

				source.GetTriangles(indices, i);

				for (var j = 0; j < indices.Count; j += 3)
				{
					AddTriangle(indices[j + 0], indices[j + 1], indices[j + 2]);
				}

				if (DebugScale > 0.0f)
				{
					for (var j = edges.Count - 1; j >= 0; j--)
					{
						var edge = edges[j];

						if (edge.Used == true)
						{
							Debug.DrawLine(edge.CoordA * DebugScale, edge.CoordB * DebugScale, new Color(1.0f, 1.0f, 1.0f, 0.5f), 1.0f);
						}
						else
						{
							Debug.DrawLine(edge.CoordA * DebugScale, edge.CoordB * DebugScale, new Color(1.0f, 1.0f, 1.0f, 0.25f), 1.0f);
						}
					}
				}

				for (var j = edges.Count - 1; j >= 0; j--)
				{
					var edge = edges[j];

					if (edge.Used == false)
					{
						edge.Used = true;

						points.Clear();

						startCoord = edge.CoordA;

						points.Add(new Point() { Index = edge.IndexA, Coord = edge.CoordA });
						points.Add(new Point() { Index = edge.IndexB, Coord = edge.CoordB });

						TraceEdges(edge.CoordB);
					}
				}

				mesh.SetVertices(positions);
				mesh.SetTriangles(indices, i);
			}
		}

		private void AddTriangle(int a, int b, int c)
		{
			var coordA = default(Vector4);
			var coordB = default(Vector4);
			var coordC = default(Vector4);

			switch (channel)
			{
				case P3dChannel.UV : coordA = coords0[a]; coordB = coords0[b]; coordC = coords0[c]; break;
				case P3dChannel.UV2: coordA = coords1[a]; coordB = coords1[b]; coordC = coords1[c]; break;
				case P3dChannel.UV3: coordA = coords2[a]; coordB = coords2[b]; coordC = coords2[c]; break;
				case P3dChannel.UV4: coordA = coords3[a]; coordB = coords3[b]; coordC = coords3[c]; break;
			}

			var ab = (Vector2)(coordB - coordA);
			var ac = (Vector2)(coordC - coordA);

			// Ignore degenerate triangles
			if (Vector3.Cross(ab, ac).sqrMagnitude >= areaThreshold)
			{
				// Clockwise?
				if (((coordB.x - coordA.x) * (coordC.y - coordA.y) - (coordC.x - coordA.x) * (coordB.y - coordA.y)) >= 0.0f)
				{
					AddTriangle(a, b, c, coordA, coordB, coordC);
				}
				else
				{
					AddTriangle(c, b, a, coordC, coordB, coordA);
				}
			}
		}

		private void AddTriangle(int a, int b, int c, Vector2 coordA, Vector2 coordB, Vector2 coordC)
		{
			RemoveOrAddEdge(a, b, coordA, coordB);
			RemoveOrAddEdge(b, c, coordB, coordC);
			RemoveOrAddEdge(c, a, coordC, coordA);
		}

		private void RemoveOrAddEdge(int a, int b, Vector2 coordA, Vector2 coordB)
		{
			for (var i = edges.Count - 1; i >= 0; i--)
			{
				var edge = edges[i];

				if (Overlap(edge.CoordB - coordA) == true)
				{
					if (Overlap(edge.CoordA - coordB) == true)
					{
						edge.Used = true; return;
					}
				}
			}

			var newEdge = new Edge();

			newEdge.IndexA = a;
			newEdge.IndexB = b;
			newEdge.CoordA = coordA;
			newEdge.CoordB = coordB;

			edges.Add(newEdge);
		}

		private void TraceEdges(Vector2 head)
		{
			var exit = false;

			while (exit == false)
			{
				exit = true;

				for (var i = edges.Count - 1; i >= 0; i--)
				{
					var edge = edges[i];

					if (edge.Used == false && Overlap(head - edge.CoordA) == true)
					{
						edge.Used = true;

						points.Add(new Point() { Index = edge.IndexB, Coord = edge.CoordB });

						head = edge.CoordB;
						exit = false;
					}
				}
			}

			// Loop?
			if (Overlap(head - startCoord) == true && points.Count > 2)
			{
				var point1 = points[1];
				var point2 = points[2];

				points.Add(new Point() { Index = point1.Index, Coord = point1.Coord });
				points.Add(new Point() { Index = point2.Index, Coord = point2.Coord });

				var index = positions.Count;

				for (var i = 1; i < points.Count - 1; i++)
				{
					var pointA    = points[i - 1];
					var pointB    = points[i    ];
					var pointC    = points[i + 1];
					var normalA   = (pointA.Coord - pointB.Coord).normalized; normalA = new Vector2(-normalA.y, normalA.x);
					var normalB   = (pointB.Coord - pointC.Coord).normalized; normalB = new Vector2(-normalB.y, normalB.x);
					var average   = normalA + normalB;
					var magnitude = average.sqrMagnitude;
					var newCoord  = pointB.Coord;

					if (magnitude > 0.0f)
					{
						magnitude = Mathf.Sqrt(magnitude);

						newCoord += (average / magnitude) * border;
					}

					AddVertex(pointB.Index, newCoord);
				}

				for (var i = 0; i < points.Count - 3; i++)
				{
					var a = points[i + 1].Index;
					var b = points[i + 2].Index;
					var c = index + i;
					var d = c + 1;

					indices.Add(a);
					indices.Add(b);
					indices.Add(c);

					indices.Add(d);
					indices.Add(c);
					indices.Add(b);

					if (DebugScale > 0.0f)
					{
						switch (channel)
						{
							case P3dChannel.UV:
							{
								Debug.DrawLine(coords0[a] * DebugScale, coords0[b] * DebugScale, Color.green, 1.0f);
								Debug.DrawLine(coords0[c] * DebugScale, coords0[d] * DebugScale, Color.blue , 1.0f);
							}
							break;

							case P3dChannel.UV2:
							{
								Debug.DrawLine(coords1[a] * DebugScale, coords1[b] * DebugScale, Color.green, 1.0f);
								Debug.DrawLine(coords1[c] * DebugScale, coords1[d] * DebugScale, Color.blue , 1.0f);
							}
							break;

							case P3dChannel.UV3:
							{
								Debug.DrawLine(coords2[a] * DebugScale, coords2[b] * DebugScale, Color.green, 1.0f);
								Debug.DrawLine(coords2[c] * DebugScale, coords2[d] * DebugScale, Color.blue , 1.0f);
							}
							break;

							case P3dChannel.UV4:
							{
								Debug.DrawLine(coords3[a] * DebugScale, coords3[b] * DebugScale, Color.green, 1.0f);
								Debug.DrawLine(coords3[c] * DebugScale, coords3[d] * DebugScale, Color.blue , 1.0f);
							}
							break;
						}
					}
				}
			}
			// Free?
			else
			{
				//var point0 = points[0];
				//var point1 = points[points.Count ];
			}
		}

		private bool Overlap(Vector2 delta)
		{
			return Vector2.SqrMagnitude(delta) <= coordThreshold;
		}

		private void AddVertex(int index, Vector2 coord)
		{
			if (boneWeights.Count > 0)
			{
				boneWeights.Add(boneWeights[index]);
			}

			if (colors.Count > 0)
			{
				colors.Add(colors[index]);
			}

			if (normals.Count > 0)
			{
				normals.Add(normals[index]);
			}

			if (tangents.Count > 0)
			{
				tangents.Add(tangents[index]);
			}

			if (coords0.Count > 0)
			{
				coords0.Add(coords0[index]);
			}

			if (coords1.Count > 0)
			{
				coords1.Add(coords1[index]);
			}

			if (coords2.Count > 0)
			{
				coords2.Add(coords2[index]);
			}

			if (coords3.Count > 0)
			{
				coords3.Add(coords3[index]);
			}

			switch (channel)
			{
				case P3dChannel.UV : if (coords0.Count > 0) coords0[coords0.Count - 1] = coord; break;
				case P3dChannel.UV2: if (coords1.Count > 0) coords1[coords1.Count - 1] = coord; break;
				case P3dChannel.UV3: if (coords2.Count > 0) coords2[coords2.Count - 1] = coord; break;
				case P3dChannel.UV4: if (coords3.Count > 0) coords3[coords3.Count - 1] = coord; break;
			}

			positions.Add(positions[index]);
		}
	}
}