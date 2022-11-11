using UnityEngine;
using UnityEditor;
using System.Collections.Generic;

namespace PaintIn3D
{
	public class P3dWindowPaintableTexture
	{
		public P3dWindowPaintable Parent;

		public int MaterialIndex;

		public string SlotName;

		public P3dGroup Group;

		public P3dChannel Channel;

		public Texture2D OldTexture;

		public RenderTexture NewTexture;

		public int SnapshotIndex;

		public List<RenderTexture> Snapshots = new List<RenderTexture>();

		public bool Locked;

		public bool LockFailed;

		public bool WriteDirty;

		public bool CanUndo()
		{
			return Locked == true && SnapshotIndex > 0;
		}

		public bool CanWrite()
		{
			if (Locked == true)
			{
				var path = AssetDatabase.GetAssetPath(OldTexture);

				return string.IsNullOrEmpty(path) == false && path.EndsWith(".png", System.StringComparison.InvariantCultureIgnoreCase) == true;
			}

			return false;
		}

		public bool NeedsWrite()
		{
			return WriteDirty == true && CanWrite() == true;
		}

		public bool CanRedo()
		{
			return Locked == true && SnapshotIndex < Snapshots.Count - 1;
		}

		public void Undo()
		{
			if (SnapshotIndex > 0)
			{
				SnapshotIndex--;

				Apply(Snapshots[SnapshotIndex]);
			}
		}

		public void Write()
		{
			WriteDirty = false;

			if (Locked == true && OldTexture != null)
			{
				var path = AssetDatabase.GetAssetPath(OldTexture);

				if (string.IsNullOrEmpty(path) == false)
				{
					if (path.EndsWith(".png", System.StringComparison.InvariantCultureIgnoreCase) == true)
					{
						P3dHelper.SaveTextureAsset(OldTexture, path, true);
					}
				}
			}
		}

		public void Redo()
		{
			if (SnapshotIndex < Snapshots.Count - 1)
			{
				SnapshotIndex++;

				Apply(Snapshots[SnapshotIndex]);
			}
		}

		public P3dWindowPaintableTexture(P3dWindowPaintable newParent, int newMaterial, string newSlotName)
		{
			Parent        = newParent;
			MaterialIndex = newMaterial;
			SlotName      = newSlotName;
		}

		public bool Lock(P3dWindow window)
		{
			if (Locked == false)
			{
				var renderer  = Parent.Root.GetComponent<Renderer>();
				var materials = renderer.sharedMaterials;
				var material  = materials[MaterialIndex];

				OldTexture = material.GetTexture(SlotName) as Texture2D;
				LockFailed = true;

				if (window.CanReadWrite(OldTexture) == true)
				{
					Locked     = true;
					LockFailed = false;

					AddSnapshot(OldTexture);
				}
			}

			return Locked;
		}

		private void AddSnapshot(Texture source)
		{
			var snapshot = P3dHelper.GetRenderTexture(source.width, source.height, 0, RenderTextureFormat.ARGB32);

			P3dHelper.Blit(snapshot, source);

			Snapshots.Add(snapshot);
		}

		public void Unlock()
		{
			if (Locked == true)
			{
				Locked = false;

				var renderer  = Parent.Root.GetComponent<Renderer>();
				var materials = renderer.sharedMaterials;
				var material  = materials[MaterialIndex];

				material.SetTexture(SlotName, OldTexture);

				NewTexture = ReleaseDelete(NewTexture);

				for (var i = Snapshots.Count - 1; i >= 0; i--)
				{
					ReleaseDelete(Snapshots[i]);
				}

				SnapshotIndex = 0;
			}
		}

		private RenderTexture ReleaseDelete(RenderTexture rt)
		{
			if (rt != null)
			{
				P3dHelper.ReleaseRenderTexture(rt);
			}

			return null;
		}

		public void Revert()
		{
			if (NewTexture != null)
			{
				var renderer  = Parent.Root.GetComponent<Renderer>();
				var materials = renderer.sharedMaterials;
				var material  = materials[MaterialIndex];

				material.SetTexture(SlotName, OldTexture);

				P3dHelper.Blit(NewTexture, OldTexture);
			}
		}

		public RenderTexture PreparePaint()
		{
			if (Locked == true)
			{
				var renderer  = Parent.Root.GetComponent<Renderer>();
				var materials = renderer.sharedMaterials;
				var material  = materials[MaterialIndex];

				if (NewTexture == null)
				{
					NewTexture = P3dHelper.GetRenderTexture(OldTexture.width, OldTexture.height, 0, RenderTextureFormat.ARGB32);

					P3dHelper.Blit(NewTexture, OldTexture);
				}

				if (NewTexture.width != OldTexture.width || NewTexture.height != OldTexture.height)
				{
					NewTexture = P3dHelper.GetRenderTexture(OldTexture.width, OldTexture.height, 0, RenderTextureFormat.ARGB32);

					P3dHelper.Blit(NewTexture, OldTexture);
				}

				material.SetTexture(SlotName, NewTexture);

				return NewTexture;
			}

			return null;
		}

		public void Apply()
		{
			if (Locked == true)
			{
				Apply(NewTexture);

				// Remove decoupled redo states
				for (var i = Snapshots.Count - 1; i > SnapshotIndex; i--)
				{
					ReleaseDelete(Snapshots[i]);

					Snapshots.RemoveAt(i);
				}

				WriteDirty = true;

				// Add snapshot
				SnapshotIndex++;

				AddSnapshot(OldTexture);

				// Remove excess
				var maxUndoSteps = Mathf.Max(P3dWindowData.Instance.MaxUndoSteps, 1);
				var excess       = Snapshots.Count - maxUndoSteps;

				if (excess > 0)
				{
					for (var i = 0; i < excess; i++)
					{
						ReleaseDelete(Snapshots[0]);
					}

					Snapshots.RemoveRange(0, excess);

					SnapshotIndex -= excess;
				}
			}
		}

		private void Apply(RenderTexture renderTexture)
		{
			var renderer  = Parent.Root.GetComponent<Renderer>();
			var materials = renderer.sharedMaterials;
			var material  = materials[MaterialIndex];

			material.SetTexture(SlotName, OldTexture);

			P3dHelper.ReadPixels(OldTexture, renderTexture);
		}
	}
}