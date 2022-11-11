using UnityEngine;
using System.Collections;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(P3dPaintable))]
	public class P3dPaintable_Editor : P3dEditor<P3dPaintable>
	{
		protected override void OnInspector()
		{
			DrawDefault("activation", "This allows you to control when this component actually activates and becomes ready for painting. You probably don't need to change this.");

			Separator();
			
			if (Any(t => t.GetComponent<P3dPaintableTexture>() == null))
			{
				EditorGUILayout.HelpBox("Your paintable doesn't have any paintable textures!", MessageType.Warning);
			}

			if (Button("Add Material Cloner") == true)
			{
				Each(t => t.gameObject.AddComponent<P3dMaterialCloner>());
			}

			if (Button("Add Paintable Texture") == true)
			{
				Each(t => t.gameObject.AddComponent<P3dPaintableTexture>());
			}

			if (Button("Analyze Mesh") == true)
			{
				P3dMeshAnalysis.OpenWith(Target.gameObject);
			}
		}
	}
}
#endif

namespace PaintIn3D
{
	/// <summary>This component marks the current GameObject as being paintable, as long as this GameObject has a MeshFilter + MeshRenderer, or a SkinnedMeshRenderer.
	/// To actually paint it also requires the SgtPaintableTexture component.</summary>
	[DisallowMultipleComponent]
	[RequireComponent(typeof(Renderer))]
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dPaintable")]
	[AddComponentMenu(P3dHelper.ComponentMenuPrefix + "Paintable")]
	public class P3dPaintable : P3dLinkedBehaviour<P3dPaintable>
	{
		public enum ActivationType
		{
			Awake,
			OnEnable,
			Start,
			OnFirstUse
		}

		/// <summary>This allows you to control when this component actually activates and becomes ready for painting. You probably don't need to change this.</summary>
		public ActivationType Activation { set { activation = value; } get { return activation; } } [SerializeField] private ActivationType activation = ActivationType.OnFirstUse;

		[SerializeField]
		private bool activated;

		[System.NonSerialized]
		private Renderer cachedRenderer;

		[System.NonSerialized]
		private bool cachedRendererSet;

		[System.NonSerialized]
		private SkinnedMeshRenderer cachedSkinned;

		[System.NonSerialized]
		private MeshFilter cachedFilter;

		[System.NonSerialized]
		private bool cachedSkinnedSet;

		[System.NonSerialized]
		private Transform cachedTransform;

		[System.NonSerialized]
		private GameObject cachedGameObject;

		[System.NonSerialized]
		private Material[] materials;

		[System.NonSerialized]
		private bool materialsSet;

		[System.NonSerialized]
		private Mesh bakedMesh;

		[System.NonSerialized]
		private bool bakedMeshSet;

		[System.NonSerialized]
		private bool prepared;

		[System.NonSerialized]
		private Mesh preparedMesh;

		[System.NonSerialized]
		private Matrix4x4 preparedMatrix;

		[System.NonSerialized]
		private List<P3dPaintableTexture> paintableTextures = new List<P3dPaintableTexture>();

		[System.NonSerialized]
		private static List<P3dPaintable> tempPaintables = new List<P3dPaintable>();

		[System.NonSerialized]
		private static List<P3dMaterialCloner> tempMaterialCloners = new List<P3dMaterialCloner>();

		public GameObject CachedGameObject
		{
			get
			{
				return cachedGameObject;
			}
		}

		public Renderer CachedRenderer
		{
			get
			{
				if (cachedRendererSet == false)
				{
					CacheRenderer();
				}

				return cachedRenderer;
			}
		}

		public Material[] Materials
		{
			get
			{
				if (materialsSet == false)
				{
					materials    = CachedRenderer.sharedMaterials;
					materialsSet = true;
				}

				return materials;
			}
		}

		private void CacheRenderer()
		{
			cachedRenderer    = GetComponent<Renderer>();
			cachedRendererSet = true;

			if (cachedRenderer is SkinnedMeshRenderer)
			{
				cachedSkinned    = (SkinnedMeshRenderer)cachedRenderer;
				cachedSkinnedSet = true;
			}
			else
			{
				cachedFilter = GetComponent<MeshFilter>();
			}
		}

		public List<P3dPaintableTexture> PaintableTextures
		{
			get
			{
				return paintableTextures;
			}
		}

		/// <summary>This will return a list of all paintables that overlap the specified bounds</summary>
		public static List<P3dPaintable> FindOverlap(Vector3 position, float sqrRadius, int layerMask)
		{
			tempPaintables.Clear();

			var paintable = FirstInstance;

			for (var i = 0; i < InstanceCount; i++)
			{
				var mask = 1 << paintable.cachedGameObject.layer;

				if ((layerMask & mask) != 0)
				{
					var bounds = paintable.CachedRenderer.bounds;

					if (Vector3.SqrMagnitude(position - bounds.center) < sqrRadius + bounds.extents.sqrMagnitude)
					{
						tempPaintables.Add(paintable);

						if (paintable.activated == false)
						{
							paintable.Activate();
						}
					}
				}

				paintable = paintable.NextInstance;
			}

			return tempPaintables;
		}

		/// <summary>Materials will give you a cached CachedRenderer.sharedMaterials array. If you have updated this array externally then call this to force the cache to update next them it's accessed.</summary>
		[ContextMenu("Dirty Materials")]
		public void DirtyMaterials()
		{
			materialsSet = false;
		}

		[ContextMenu("Activate")]
		public void Activate()
		{
			// Activate material cloners
			GetComponents(tempMaterialCloners);

			for (var i = tempMaterialCloners.Count - 1; i >= 0; i--)
			{
				tempMaterialCloners[i].Activate();
			}

			// Activate textures
			GetComponents(paintableTextures);

			for (var i = paintableTextures.Count - 1; i >= 0; i--)
			{
				paintableTextures[i].Activate();
			}

			activated = true;
		}

		public void ClearAll(Color color)
		{
			ClearAll(default(Texture), color);
		}

		public void ClearAll(Texture texture, Color color)
		{
			if (activated == true)
			{
				for (var i = paintableTextures.Count - 1; i >= 0; i--)
				{
					paintableTextures[i].Clear(texture, color);
				}
			}
		}

		public void Register(P3dPaintableTexture paintableTexture)
		{
			for (var i = paintableTextures.Count - 1; i >= 0; i--)
			{
				if (paintableTextures[i] == paintableTexture)
				{
					return;
				}
			}

			paintableTextures.Add(paintableTexture);
		}

		public void Unregister(P3dPaintableTexture paintableTexture)
		{
			for (var i = paintableTextures.Count - 1; i >= 0; i--)
			{
				if (paintableTextures[i] == paintableTexture)
				{
					paintableTextures.RemoveAt(i);
				}
			}
		}

		public void UpdateFromManager()
		{
			if (activated == true)
			{
				prepared = false;

				for (var i = paintableTextures.Count - 1; i >= 0; i--)
				{
					paintableTextures[i].ExecuteCommands(this);
				}
			}
		}

		public void GetPrepared(ref Mesh mesh, ref Matrix4x4 matrix)
		{
			if (prepared == false)
			{
				prepared = true;

				if (cachedSkinnedSet == true)
				{
					if (bakedMeshSet == false)
					{
						bakedMesh    = new Mesh();
						bakedMeshSet = true;
					}

					var scaling       = P3dHelper.Reciprocal3(cachedTransform.lossyScale);
					var oldLocalScale = cachedTransform.localScale;

					cachedTransform.localScale = Vector3.one;

					cachedSkinned.BakeMesh(bakedMesh);

					cachedTransform.localScale = oldLocalScale;

					preparedMesh   = bakedMesh;
					preparedMatrix = cachedTransform.localToWorldMatrix * Matrix4x4.Scale(scaling);
				}
				else
				{
					preparedMesh   = cachedFilter.sharedMesh;
					preparedMatrix = transform.localToWorldMatrix;
				}
			}

			mesh   = preparedMesh;
			matrix = preparedMatrix;
		}

		protected virtual void Awake()
		{
			if (activation == ActivationType.Awake && activated == false)
			{
				Activate();
			}
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			cachedGameObject = gameObject;
			cachedTransform  = transform;

			if (cachedRendererSet == false)
			{
				CacheRenderer();
			}

			if (activation == ActivationType.OnEnable && activated == false)
			{
				Activate();
			}

			if (P3dPaintableManager.InstanceCount == 0)
			{
				var paintableManager = new GameObject(typeof(P3dPaintableManager).Name);

				paintableManager.hideFlags = HideFlags.DontSave;
				
				paintableManager.AddComponent<P3dPaintableManager>();
			}
		}

		protected virtual void Start()
		{
			if (activation == ActivationType.Start && activated == false)
			{
				Activate();
			}
		}

		protected virtual void OnDestroy()
		{
			P3dHelper.Destroy(bakedMesh);
		}
	}
}