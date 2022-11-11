using UnityEngine;
using UnityEngine.Events;
using System.Collections.Generic;

#if UNITY_EDITOR
using UnityEditor;

namespace PaintIn3D
{
	[CanEditMultipleObjects]
	[CustomEditor(typeof(P3dPaintableTexture))]
	public class P3dPaintableTexture_Editor : P3dEditor<P3dPaintableTexture>
	{
		private static List<IPaintHandler> paintHandlers = new List<IPaintHandler>();

		protected override void OnInspector()
		{
			if (All(t => t.Activated == true))
			{
				EditorGUILayout.HelpBox("This component has already activated.", MessageType.Info);
			}

			if (Any(t => t.Activated == false))
			{
				DrawDefault("slot", "The material slot and texture name that will be painted.");
				DrawDefault("channel", "The UV channel this texture is mapped to.");
				BeginDisabled();
					EditorGUI.ObjectField(P3dHelper.Reserve(), "Texture", Target.Slot.FindTexture(Target.gameObject), typeof(Texture), false);
				EndDisabled();

				Separator();

				DrawDefault("group", "The group you want to associate this texture with. You only need to set this if you are painting multiple types of textures at the same time (e.g. 0 = albedo, 1 = illumination).");
				DrawDefault("stateLimit", "The amount of times this texture can have its paint operations undone.");
				DrawDefault("saveName", "If you want this texture to automatically save/load, then you can set the unique save name for it here. Keep in mind this setting won't work properly with prefab spawning since all clones will share the same SaveName.");
				DrawDefault("shaderKeyword", "Some shaders require specific shader keywords to be enabled when adding new textures. If there is no texture in your selected slot then you may need to set this keyword.");

				Separator();

				DrawDefault("format", "The format of the created texture.");
				DrawDefault("width", "The base width of the created texture.");
				DrawDefault("height", "The base height of the created texture.");
				DrawDefault("inheritSize", "If there is already a texture in the specified slot, inherit the width/height of that texture?");
				DrawDefault("baseScale", "If you want the width/height to be multiplied by the scale of this GameObject, this allows you to set the scale where you want the multiplier to be 1.");
				DrawDefault("color", "The base color of the created texture.");
				DrawDefault("texture", "The format of the created texture.");
			}

			Target.GetComponentsInChildren(paintHandlers);

			if (paintHandlers.Count > 0)
			{
				Separator();

				for (var i = 0; i < paintHandlers.Count; i++)
				{
					EditorGUILayout.HelpBox("This component is sending paint events to " + paintHandlers[i], MessageType.Info);
				}
			}
		}
	}
}
#endif

namespace PaintIn3D
{
	/// <summary>This component allows you to make one texture on the attached Renderer paintable.</summary>
	[RequireComponent(typeof(Renderer))]
	[RequireComponent(typeof(P3dPaintable))]
	[HelpURL(P3dHelper.HelpUrlPrefix + "P3dPaintableTexture")]
	[AddComponentMenu(P3dHelper.ComponentMenuPrefix + "Paintable Texture")]
	public class P3dPaintableTexture : P3dLinkedBehaviour<P3dPaintableTexture>
	{
		[System.Serializable] public class PaintableTextureEvent : UnityEvent<P3dPaintableTexture> {}

		/// <summary>The material index and texture slot name that will be used.</summary>
		public P3dSlot Slot { set { slot = value; } get { return slot; } } [SerializeField] private P3dSlot slot = new P3dSlot(0, "_MainTex");

		/// <summary>The UV channel this texture is mapped to.</summary>
		public P3dChannel Channel { set { channel = value; } get { return channel; } } [SerializeField] private P3dChannel channel;

		/// <summary>The group you want to associate this texture with. You only need to set this if you are painting multiple types of textures at the same time (e.g. 0 = albedo, 1 = illumination).</summary>
		public P3dGroup Group { set { group = value; } get { return group; } } [SerializeField] private P3dGroup group;

		/// <summary>The amount of times this texture can have its paint operations undone.</summary>
		public int StateLimit { set { stateLimit = value; } get { return stateLimit; } } [SerializeField] private int stateLimit;

		/// <summary>If you want this texture to automatically save/load, then you can set the unique save name for it here. Keep in mind this setting won't work properly with prefab spawning since all clones will share the same SaveName.</summary>
		public string SaveName { set { saveName = value; } get { return saveName; } } [SerializeField] private string saveName;

		/// <summary>Some shaders require specific shader keywords to be enabled when adding new textures. If there is no texture in your selected slot then you may need to set this keyword.</summary>
		public string ShaderKeyword { set { shaderKeyword = value; } get { return shaderKeyword; } } [SerializeField] private string shaderKeyword;

		/// <summary>The format of the created texture.</summary>
		public RenderTextureFormat Format { set { format = value; } get { return format; } } [SerializeField] private RenderTextureFormat format;

		/// <summary>The base width of the created texture.</summary>
		public int Width { set { width = value; } get { return width; } } [SerializeField] private int width = 512;

		/// <summary>The base height of the created texture.</summary>
		public int Height { set { height = value; } get { return height; } } [SerializeField] private int height = 512;

		/// <summary>If there is already a texture in the specified slot, inherit the width/height of that texture?</summary>
		public bool InheritSize { set { inheritSize = value; } get { return inheritSize; } } [SerializeField] private bool inheritSize = true;

		/// <summary>If you want the width/height to be multiplied by the scale of this GameObject, this allows you to set the scale where you want the multiplier to be 1.</summary>
		public Vector3 BaseScale { set { baseScale = value; } get { return baseScale; } } [SerializeField] private Vector3 baseScale;

		/// <summary>The base color of the created texture.</summary>
		public Color Color { set { color = value; } get { return color; } } [SerializeField] private Color color = Color.white;

		/// <summary>The base texture of the created texture.</summary>
		public Texture Texture { set { texture = value; } get { return texture; } } [SerializeField] private Texture texture;

		public bool Activated
		{
			get
			{
				return activated;
			}
		}

		public bool CanUndo
		{
			get
			{
				return stateIndex > 0;
			}
		}

		public bool CanRedo
		{
			get
			{
				return states != null && stateIndex < states.Count - 1;
			}
		}

		[SerializeField]
		private bool activated;

		[SerializeField]
		private RenderTexture current;

		[SerializeField]
		private RenderTexture preview;

		[SerializeField]
		private bool previewSet;

		[System.NonSerialized]
		private List<RenderTexture> states;

		[System.NonSerialized]
		private int stateIndex;

		[System.NonSerialized]
		private P3dPaintable paintable;

		[System.NonSerialized]
		private bool paintableSet;

		[System.NonSerialized]
		private Material material;

		[System.NonSerialized]
		private bool materialSet;

		[System.NonSerialized]
		private List<P3dCommand> commands = new List<P3dCommand>();

		[System.NonSerialized]
		private List<IPaintHandler> paintHandlers = new List<IPaintHandler>();

		[System.NonSerialized]
		private static List<P3dPaintableTexture> tempPaintableTextures = new List<P3dPaintableTexture>();

		/// <summary>This will get the current texture.</summary>
		public RenderTexture Current
		{
			set
			{
				if (materialSet == true)
				{
					current = value;

					material.SetTexture(slot.Name, current);
				}
			}

			get
			{
				return current;
			}
		}

		/// <summary>This will get the preview texture.</summary>
		public RenderTexture Preview
		{
			get
			{
				return preview;
			}
		}

		public static List<P3dPaintableTexture> Filter(P3dPaintable paintable, int groupMask)
		{
			tempPaintableTextures.Clear();

			var paintableTextures = paintable.PaintableTextures;

			for (var i = paintableTextures.Count - 1; i >= 0; i--)
			{
				var paintableTexture = paintableTextures[i];
				var mask             = 1 << paintableTexture.group;

				if ((mask & groupMask) != 0)
				{
					tempPaintableTextures.Add(paintableTexture);
				}
			}

			return tempPaintableTextures;
		}

		/// <summary>This will clear all undo/redo texture states.</summary>
		[ContextMenu("Clear States")]
		public void ClearStates()
		{
			if (states != null)
			{
				for (var i = states.Count - 1; i >= 0; i--)
				{
					P3dHelper.ReleaseRenderTexture(states[i]);
				}

				states.Clear();

				stateIndex = 0;
			}
		}

		/// <summary>This will store a texture state so that it can later be undone. This should be called before you perform texture modifications.</summary>
		[ContextMenu("Store State")]
		public void StoreState()
		{
			if (activated == true)
			{
				if (states == null)
				{
					states = new List<RenderTexture>();
				}

				// If this is the latest state, then don't store or trim future
				if (stateIndex != states.Count - 1)
				{
					TrimFuture();

					AddState();
				}

				TrimPast();

				stateIndex = states.Count;
			}
		}

		/// <summary>This will revert the texture to a previous state, if you have an undo state stored.</summary>
		[ContextMenu("Undo")]
		public void Undo()
		{
			if (CanUndo == true)
			{
				// If we're undoing for the first time, store the current state so we can redo back to it
				if (stateIndex == states.Count)
				{
					AddState();
				}

				var state = states[--stateIndex];

				P3dHelper.Blit(current, state);
			}
		}

		/// <summary>This will restore a previously undone texture state, if you've performed an undo.</summary>
		[ContextMenu("Redo")]
		public void Redo()
		{
			if (CanRedo == true)
			{
				var state = states[++stateIndex];

				P3dHelper.Blit(current, state);
			}
		}

		private void AddState()
		{
			var state = P3dHelper.GetRenderTexture(current.width, current.height, 0, current.format);

			P3dHelper.Blit(state, current);

			states.Add(state);
		}

		private void TrimFuture()
		{
			for (var i = states.Count - 1; i >= stateIndex; i--)
			{
				P3dHelper.ReleaseRenderTexture(states[i]);

				states.RemoveAt(i);
			}
		}

		private void TrimPast()
		{
			for (var i = states.Count - stateLimit - 1; i >= 0; i--)
			{
				P3dHelper.ReleaseRenderTexture(states[i]);

				states.RemoveAt(i);
			}
		}

		/// <summary>You should call this after painting to this paintable texture.</summary>
		public void NotifyOnModified(bool preview)
		{
			if (paintHandlers.Count == 0)
			{
				GetComponentsInChildren(paintHandlers);
			}

			for (var i = 0; i < paintHandlers.Count; i++)
			{
				paintHandlers[i].HandlePaint(this, preview);
			}
		}

		public void Clear(Color color)
		{
			Clear(default(Texture), color);
		}

		public void Clear(Texture texture, Color color)
		{
			if (activated == true)
			{
				P3dPainter.Replace.Blit(current, texture, color);
			}
		}

		[ContextMenu("Save")]
		public void Save()
		{
			Save(saveName);
		}

		public void Save(string saveName)
		{
			if (activated == true)
			{
				var readableTexture = P3dHelper.GetReadableTexture(current);

				P3dHelper.SavePngTextureData(readableTexture.EncodeToPNG(), saveName);

				P3dHelper.Destroy(readableTexture);
			}
		}

		[ContextMenu("Load")]
		public void Load()
		{
			Load(saveName);
		}

		public void Load(string saveName)
		{
			if (activated == true && current != null)
			{
				var tempTexture = default(Texture2D);

				if (P3dHelper.TryLoadTexture(saveName, ref tempTexture) == true)
				{
					P3dHelper.Blit(current, tempTexture);

					P3dHelper.Destroy(tempTexture);
				}
			}
		}

		[ContextMenu("Clear Save")]
		public void ClearSave()
		{
			P3dHelper.ClearTexture(saveName);
		}

		/// <summary>If you modified the slot material index, then call this to update the cached material.</summary>
		[ContextMenu("Update Material")]
		public void UpdateMaterial()
		{
			material    = P3dHelper.GetMaterial(gameObject, slot.Index);
			materialSet = true;
		}

		[ContextMenu("Activate")]
		public void Activate()
		{
			if (activated == false)
			{
				UpdateMaterial();

				if (material != null)
				{
					var finalWidth   = width;
					var finalHeight  = height;
					var finalTexture = material.GetTexture(slot.Name);

					if (inheritSize == true && finalTexture != null)
					{
						finalWidth  = finalTexture.width;
						finalHeight = finalTexture.height;
					}

					if (baseScale != Vector3.zero)
					{
						var scale = transform.localScale.magnitude / baseScale.magnitude;

						finalWidth  = Mathf.CeilToInt(finalWidth  * scale);
						finalHeight = Mathf.CeilToInt(finalHeight * scale);
					}

					if (texture != null)
					{
						finalTexture = texture;
					}

					if (string.IsNullOrEmpty(shaderKeyword) == false)
					{
						material.EnableKeyword(shaderKeyword);
					}

					current = P3dHelper.GetRenderTexture(finalWidth, finalHeight, 0, format);

					P3dPainter.Replace.Blit(current, finalTexture, color);

					material.SetTexture(slot.Name, current);

					activated = true;

					if (string.IsNullOrEmpty(saveName) == false)
					{
						Load();
					}

					NotifyOnModified(false);
				}
			}
		}

		protected override void OnEnable()
		{
			base.OnEnable();

			if (paintableSet == false)
			{
				paintable    = GetComponent<P3dPaintable>();
				paintableSet = true;
			}

			paintable.Register(this);
		}

		protected override void OnDisable()
		{
			paintable.Unregister(this);
		}

		protected virtual void OnDestroy()
		{
			if (activated == true)
			{
				if (string.IsNullOrEmpty(saveName) == false)
				{
					Save();
				}

				P3dHelper.ReleaseRenderTexture(current);

				if (previewSet == true)
				{
					P3dHelper.ReleaseRenderTexture(preview);
				}

				ClearStates();
			}
		}

		public T AddCommand<T>(List<T> pool, ref int poolCount, bool preview)
			where T : P3dCommand, new()
		{
			var command = default(T);

			if (poolCount > 0)
			{
				poolCount--;

				command = pool[poolCount];

				pool.RemoveAt(poolCount);
			}
			else
			{
				command = new T();
			}

			command.Preview = preview;

			commands.Add(command);

			return command;
		}

		public bool CommandsPending
		{
			get
			{
				return commands.Count > 0;
			}
		}

		public void ExecuteCommands(P3dPaintable paintable)
		{
			if (activated == true)
			{
				var commandCount = commands.Count;
				var swap         = default(RenderTexture);
				var swapSet      = false;

				// Revert snapshot
				if (previewSet == true)
				{
					P3dHelper.ReleaseRenderTexture(preview); previewSet = false;
				}

				if (commandCount > 0)
				{
					var oldActive      = RenderTexture.active;
					var prepared       = false;
					var preparedMesh   = default(Mesh);
					var preparedMatrix = default(Matrix4x4);

					RenderTexture.active = current;

					for (var i = 0; i < commandCount; i++)
					{
						var command         = commands[i];
						var commandMaterial = command.Material;

						if (command.Preview != previewSet)
						{
							NotifyOnModified(previewSet);

							if (previewSet == true)
							{
								P3dHelper.ReleaseRenderTexture(preview); previewSet = false;

								RenderTexture.active = current;
							}
							else
							{
								preview = P3dHelper.GetRenderTexture(current.width, current.height, current.depth, current.format); previewSet = true;

								P3dHelper.Blit(preview, current);

								RenderTexture.active = preview;
							}
						}

						if (command.RequireSwap == true)
						{
							if (swapSet == false)
							{
								swap = P3dHelper.GetRenderTexture(current.width, current.height, current.depth, current.format); swapSet = true;
							}

							RenderTexture.active = swap;

							if (previewSet == true)
							{
								swap    = preview;
								preview = RenderTexture.active;
							}
							else
							{
								swap    = current;
								current = RenderTexture.active;
							}

							command.Material.SetTexture(P3dShader._Buffer, swap);
						}

						command.Apply();

						if (command.RequireMesh == true)
						{
							if (prepared == false)
							{
								prepared = true;

								paintable.GetPrepared(ref preparedMesh, ref preparedMatrix);
							}

							switch (channel)
							{
								case P3dChannel.UV : commandMaterial.SetVector(P3dShader._Channel, new Vector4(1.0f, 0.0f, 0.0f, 0.0f)); break;
								case P3dChannel.UV2: commandMaterial.SetVector(P3dShader._Channel, new Vector4(0.0f, 1.0f, 0.0f, 0.0f)); break;
								case P3dChannel.UV3: commandMaterial.SetVector(P3dShader._Channel, new Vector4(0.0f, 0.0f, 1.0f, 0.0f)); break;
								case P3dChannel.UV4: commandMaterial.SetVector(P3dShader._Channel, new Vector4(0.0f, 0.0f, 0.0f, 1.0f)); break;
							}

							commandMaterial.SetPass(0);

							Graphics.DrawMeshNow(preparedMesh, preparedMatrix, slot.Index);
						}
						else
						{
							Graphics.Blit(default(Texture), current, commandMaterial);
						}

						command.Pool();
					}

					RenderTexture.active = oldActive;

					commands.Clear();
				}

				if (swapSet == true)
				{
					P3dHelper.ReleaseRenderTexture(swap); swapSet = false;
				}

				if (commandCount > 0)
				{
					NotifyOnModified(previewSet);
				}

				if (materialSet == false)
				{
					UpdateMaterial();
				}

				if (previewSet == true)
				{
					material.SetTexture(slot.Name, preview);
				}
				else
				{
					material.SetTexture(slot.Name, current);
				}
			}
		}
	}
}