using UnityEngine;

namespace PaintIn3D
{
	public static class P3dQuad
	{
		[System.NonSerialized]
		private static Mesh mesh;

		[System.NonSerialized]
		private static bool meshSet;

		[System.NonSerialized]
		private static Vector3[] positions = new Vector3[] { new Vector3(-1.0f, -1.0f, 0.0f), new Vector3(1.0f, -1.0f, 0.0f), new Vector3(-1.0f, 1.0f, 0.0f), new Vector3(1.0f, 1.0f, 0.0f) };

		[System.NonSerialized]
		private static Vector2[] coords = new Vector2[] { new Vector2(0.0f, 0.0f), new Vector2(1.0f, 0.0f), new Vector2(0.0f, 1.0f), new Vector2(1.0f, 1.0f) };

		[System.NonSerialized]
		private static int[] indices = new int[] { 0, 1, 2, 3, 2, 1 };

		public static Mesh Mesh
		{
			get
			{
				if (meshSet == false)
				{
					mesh    = new Mesh();
					meshSet = true;
#if UNITY_EDITOR
					mesh.hideFlags = HideFlags.HideAndDontSave;
#endif
					mesh.name      = "Canvas";
					mesh.vertices  = positions;
					mesh.uv        = coords;
					mesh.triangles = indices;
				}

				return mesh;
			}
		}
	}
}