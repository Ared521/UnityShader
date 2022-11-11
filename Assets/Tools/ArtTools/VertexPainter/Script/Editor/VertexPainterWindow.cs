using System.Collections;
using UnityEditor;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEditor.SceneManagement;

public enum BrushChannel
{
	all = 0,
	red,
	green,
	blue,
	alpha
}

public class VertexPainterWindow : EditorWindow
{
    [MenuItem("美术/Vertex Painter",false,1002)]
    public static void ShowWindow()
    {
		var window = GetWindow<VertexPainterWindow>();
		window.titleContent = new GUIContent("VertexPainter");
        window.InitMeshes();
        window.Show();
    }

    public bool enabled = false;

    bool painting = false;

    public Color brushColor = Color.red;
	public static string[] channelGroup = new string[]{"All:~","Red:1","Green:2","Blue:3","Alpha:4"};
	public BrushChannel brushChannel = BrushChannel.red;
	public float currentBrushStrengh = 1.0f;
	public Color currentBrushColor = Color.white;

    public PaintingObject[] jobs = new PaintingObject[0];
    public bool[] jobEdits = new bool[0];
    public float brushSize = 1;
    public float brushFlow = 0.5f;
    public float brushFalloff = 1;

    public bool showPoint = true;
    public bool is_weightmode = false;

    private void InitMeshes()
    {
		foreach(var obj in jobs)
		{
			obj.RevertMesh();
		}
        List<PaintingObject> pjs = new List<PaintingObject>();
        UnityEngine.Object[] objs = Selection.GetFiltered(typeof(GameObject), SelectionMode.Editable | SelectionMode.Editable | SelectionMode.Deep);
        for (int i = 0; i < objs.Length; ++i)
        {
            GameObject go = objs[i] as GameObject;
			if (go != null)
			{
				SkinnedMeshRenderer skinMr = go.GetComponent<SkinnedMeshRenderer>();
				if (skinMr != null)
				{
					if (skinMr != null && skinMr.sharedMesh != null)
					{
						if (skinMr.sharedMesh.isReadable == false)
						{
							int instanceID = skinMr.sharedMesh.GetInstanceID();
							var path = AssetDatabase.GetAssetPath(instanceID);
							var importer = ModelImporter.GetAtPath(path) as ModelImporter;
							importer.isReadable = true;
							importer.SaveAndReimport();
						}
						pjs.Add(new PaintingObject(skinMr));
					}
				}
				else
				{
					MeshFilter mf = go.GetComponent<MeshFilter>();
					Renderer r = go.GetComponent<Renderer>();
					if (mf != null && r != null && mf.sharedMesh != null && mf.sharedMesh.isReadable)
					{
						if (mf.sharedMesh.isReadable == false)
						{
							int instanceID = mf.sharedMesh.GetInstanceID();
							var path = AssetDatabase.GetAssetPath(instanceID);
							var importer = ModelImporter.GetAtPath(path) as ModelImporter;
							importer.isReadable = true;
							importer.SaveAndReimport();
						}
						pjs.Add(new PaintingObject(mf, r));
					}
				}
			}
        }

        jobs = pjs.ToArray();
        jobEdits = new bool[jobs.Length];
		GC.Collect();
    }

	private void ExportPaintingData()
	{ 
		foreach(var obj in jobs)
		{ 
			if(obj._stream != null)
			{
                if (obj.skinMeshRenderer == null)
                {
                    int instanceID = obj.meshFilter.sharedMesh.GetInstanceID();
                    var path = AssetDatabase.GetAssetPath(instanceID);
                    path = path.Split('.')[0];
                    path += obj.meshFilter.gameObject.name + "_vc.asset";
                    var vertexCols = CreateInstance<MeshVertexColor>();
                    vertexCols._colors = obj._stream.colors;
                    AssetDatabase.CreateAsset(vertexCols, path);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                    vertexCols = AssetDatabase.LoadAssetAtPath<MeshVertexColor>(path);
                    PaintingData paintingData = obj.meshFilter.gameObject.GetComponent<PaintingData>();
                    if (paintingData == null)
                    {
                        paintingData = obj.meshFilter.gameObject.AddComponent<PaintingData>();
                    }
                    paintingData.savedColors = vertexCols;
                    paintingData.colors = vertexCols._colors;
                    paintingData.Apply();
                    EditorSceneManager.MarkSceneDirty(UnityEngine.SceneManagement.SceneManager.GetActiveScene());
                }
                else
                {
                    int instanceID = obj.skinMeshRenderer.sharedMesh.GetInstanceID();
                    var path = AssetDatabase.GetAssetPath(instanceID);
                    path = path.Split('.')[0];
                    path += obj.tempGo.name + "_vc.asset";
                    var vertexCols = CreateInstance<MeshVertexColor>();
                    vertexCols._colors = obj._stream.colors;
                    AssetDatabase.CreateAsset(vertexCols, path);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();
                    vertexCols = AssetDatabase.LoadAssetAtPath<MeshVertexColor>(path);
                    PaintingData paintingData = obj.skinMeshRenderer.gameObject.GetComponent<PaintingData>();
                    if (paintingData == null)
                    {
                        paintingData = obj.skinMeshRenderer.gameObject.AddComponent<PaintingData>();
                    }
                    paintingData.savedColors = vertexCols;
                    paintingData.colors = vertexCols._colors;
                    paintingData.Apply();
                    EditorSceneManager.MarkSceneDirty(UnityEngine.SceneManagement.SceneManager.GetActiveScene());
                }
			}
		}
	}

    Tool LastTool = Tool.None;
    void OnGUI()
    {

        if (Selection.activeGameObject == null)
        {
            EditorGUILayout.LabelField("No objects selected.");

            EditorGUILayout.Separator();
            GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
            EditorGUILayout.Separator();

            if (GUILayout.Button("Save", GUILayout.Height(40)))
            {
				ExportPaintingData();
            }

            enabled = false;
            return;
        }

        EditorGUILayout.Separator();
        string showText = "Paint Mode";
        if (!enabled)
        {
            GUI.backgroundColor = Color.red;
        }
        else
        {
            GUI.backgroundColor = Color.green;
            showText = "Paint Mode ( Exit )";
        }

        if (GUILayout.Button(showText, GUILayout.Height(40)))
        {
            enabled = !enabled;
            if (enabled)
            {
                InitMeshes();
                LastTool = Tools.current;
                Tools.current = Tool.None;
            }
            else
            {
                Tools.current = LastTool;
            }
        }

        GUI.backgroundColor = Color.white;

        EditorGUILayout.Separator();
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
        EditorGUILayout.Separator();

        showPoint = EditorGUILayout.Toggle("Show Vertex Point", showPoint);

        EditorGUILayout.Separator();
        GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
        EditorGUILayout.Separator();

		GUILayout.Label("笔刷缩放：滚轮,按住Alt可以微调");
		GUILayout.Label("笔刷透明度：Ctrl + 滚轮");
		GUILayout.Label("按住Shift键为减法");

		EditorGUILayout.Separator();
		GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
		EditorGUILayout.Separator();

		//GUI.backgroundColor = Color.red;
		//if (GUILayout.Button("1"))
		//{
		//	brushColor = Color.red;
		//	brushChannel = BrushChannel.red;
		//}
		//GUI.backgroundColor = Color.green;
		//if (GUILayout.Button("2"))
		//{
		//	brushColor = Color.green;
		//	brushChannel = BrushChannel.green;
		//}
		//GUI.backgroundColor = Color.blue;
		//if (GUILayout.Button("3"))
		//{
		//	brushColor = Color.blue;
		//	brushChannel = BrushChannel.blue;
		//}
		if (enabled)
		{
            is_weightmode = EditorGUILayout.Toggle("是否权重模式", is_weightmode);
            brushChannel = (BrushChannel)GUILayout.Toolbar((int)brushChannel, channelGroup);
			switch (brushChannel)
			{
				case BrushChannel.all:
					brushColor = Color.white;
					brushChannel = BrushChannel.all;
					break;
				case BrushChannel.red:
					brushColor = Color.red;
					brushChannel = BrushChannel.red;
					break;
				case BrushChannel.green:
					brushColor = Color.green;
					brushChannel = BrushChannel.green;
					break;
				case BrushChannel.blue:
					brushColor = Color.blue;
					brushChannel = BrushChannel.blue;
					break;
				case BrushChannel.alpha:
					brushColor = Color.gray;
					brushChannel = BrushChannel.alpha;
					break;
			}
			EditorGUILayout.Separator();
			GUILayout.BeginHorizontal();
			//GUILayout.FlexibleSpace();
			//GUILayout.Label("currentBrushStrengh:");
			GUI.backgroundColor = brushColor;
			if (brushChannel == BrushChannel.all)
				currentBrushColor = EditorGUILayout.ColorField("currentBrushColor", currentBrushColor);
			//else
			//	currentBrushStrengh = EditorGUILayout.Slider(currentBrushStrengh, 0.0f, 1.0f);
			GUI.backgroundColor = Color.white;
			GUILayout.EndHorizontal();
		}
		EditorGUILayout.Separator();
		GUILayout.Box("", new GUILayoutOption[] { GUILayout.ExpandWidth(true), GUILayout.Height(1) });
		EditorGUILayout.Separator();

        brushSize = EditorGUILayout.Slider("Size", brushSize, 0.01f, 20.0f);
        brushFlow = EditorGUILayout.Slider("Opacity", brushFlow, 0.1f, 2.0f);
        brushFalloff = EditorGUILayout.Slider("Falloff", brushFalloff, 0.1f, 3.5f);
        EditorGUILayout.Space();
        fill = EditorGUILayout.Toggle("填充", fill);
    }

    bool drag = false;
    bool fill = false;

    void OnSceneGUI(SceneView sceneView)
    {
        if (jobs.Length == 0 && Selection.activeGameObject != null)
        {
            InitMeshes();
        }
        if (!enabled || jobs.Length == 0 || Selection.activeGameObject == null)
        {
            return;
        }

        ShortcutsUpdate();

        if (Tools.current != Tool.None)
        {
            LastTool = Tools.current;
            Tools.current = Tool.None;
        }

        if (Event.current.rawType == EventType.MouseUp)
        {
            EndStroke();
            drag = false;
            painting = false;
        }
        if (Event.current.isMouse && painting)
        {
            Event.current.Use();
        }
        if (Event.current.type == EventType.Layout)
        {
            HandleUtility.AddDefaultControl(GUIUtility.GetControlID(GetHashCode(), FocusType.Passive));
        }

        if (Event.current.alt)
        {
            return;
        }

        bool registerUndo = (Event.current.type == EventType.MouseDown && Event.current.button == 0);

        if (registerUndo)
        {
            drag = true;
            painting = true;
            for (int x = 0; x < jobEdits.Length; ++x)
            {
                jobEdits[x] = false;
            }
        }

        if (Event.current.type != EventType.Repaint)
        {
            return;
        }

        RaycastHit hit;
        float distance = float.MaxValue;
        Vector3 mousePosition = Event.current.mousePosition;
        float mult = EditorGUIUtility.pixelsPerPoint;
        mousePosition.y = sceneView.camera.pixelHeight - mousePosition.y * mult;
        mousePosition.x *= mult;
        Vector3 fakeMP = mousePosition;
        fakeMP.z = 20;
        Vector3 point = sceneView.camera.ScreenToWorldPoint(fakeMP);
        Vector3 normal = Vector3.forward;
        Ray ray = sceneView.camera.ScreenPointToRay(mousePosition);

        for (int i = 0; i < jobs.Length; ++i)
        {
            if (jobs[i] == null || jobs[i].meshFilter == null)
                continue;

            Bounds b = jobs[i].renderer.bounds;
            b.Expand(brushSize * 2);
            if (!b.IntersectRay(ray))
            {
                continue;
            }

            Matrix4x4 mtx = jobs[i].meshFilter.transform.localToWorldMatrix;
            Mesh msh = jobs[i].meshFilter.sharedMesh;

            if (jobs[i].HasStream())
            {
                msh = jobs[i].stream.GetModifierMesh();
                InitColors(jobs[i]);
            }
            else
            {
                jobs[i].EnforceStream();
            }
            if (msh == null)
            {
                msh = jobs[i].meshFilter.sharedMesh;
            }

            if (RayMesh.IntersectRayMesh(ray, msh, mtx, out hit))
            {
                if (hit.distance < distance)
                {
                    distance = hit.distance;
                    point = hit.point;
                    normal = hit.normal;
                    if (normal.magnitude < 0.1f)
                    {
                        RayMesh.IntersectRayMesh(ray, jobs[i].meshFilter.sharedMesh, mtx, out hit);
                        normal = hit.normal;
                    }
                }
            }

            if (painting)
            {
                if (jobEdits[i] == false)
                {
                    jobEdits[i] = true;
                    Undo.RegisterCompleteObjectUndo(jobs[i].stream, "Vertex Painter Stroke");
                }
                DrawVertexPoints(jobs[i], point);
                Undo.RecordObject(jobs[i].stream, "Vertex Painter Stroke");
            }
            else
            {
                DrawVertexPoints(jobs[i], point);
            }
        }

        Handles.color = new Color(brushColor.r, brushColor.g, brushColor.b, 1.0f);
        float r = Mathf.Pow(0.5f, brushFalloff);
        Handles.DrawWireDisc(point, normal, brushSize * r);
        Handles.DrawWireDisc(point, normal, brushSize);
        //Handles.color = new Color(brushColor.r, brushColor.g, brushColor.b, 0.25f * (brushFlow / 2.0f));
        Handles.color = Color.white;
        Handles.DrawLine(point, point + normal * 0.2f);
        //Handles.DrawSolidDisc(point, normal, brushSize);

        HandleUtility.Repaint();
    }


    void ShortcutsUpdate()
    {
		//if (Event.current.keyCode == KeyCode.Escape)
		//{
		//	enabled = !enabled;
		//	if (enabled)
		//	{
		//		InitMeshes();
		//		Event.current.Use();
		//	}
		//	else
		//	{
		//		Tools.current = LastTool;
		//	}
		//}
		if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.BackQuote)
		{
			Event.current.Use();
			brushChannel = BrushChannel.all;
			brushColor = Color.white;
		}
        if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.Alpha1)
        {
            Event.current.Use();
			brushChannel = BrushChannel.red;
            brushColor = Color.red;
        }
        if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.Alpha2)
        {
            Event.current.Use();
			brushChannel = BrushChannel.green;
            brushColor = Color.green;
        }
        if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.Alpha3)
        {
            Event.current.Use();
			brushChannel = BrushChannel.blue;
            brushColor = Color.blue;
        }
		if (Event.current.type == EventType.KeyDown && Event.current.keyCode == KeyCode.Alpha4)
		{
			Event.current.Use();
			brushChannel = BrushChannel.alpha;
			brushColor = Color.gray;
		}
		if (Event.current.shift == true)
		{
			currentBrushStrengh = 0.0f;
		}
		else
		{
			currentBrushStrengh = 1.0f;
		}
		if (Event.current.type == EventType.ScrollWheel && Event.current.shift == true)
		{
			Event.current.Use();
			currentBrushStrengh -= Event.current.delta.y * 0.01f;
		}
        if (Event.current.type == EventType.ScrollWheel && Event.current.control == false)
        {
            Event.current.Use();
            brushSize -= Event.current.delta.y * 0.005f;
        }

        if (Event.current.type == EventType.ScrollWheel && Event.current.control == true)
        {
            Event.current.Use();
            brushFlow -= Event.current.delta.y * 0.05f;
        }
    }


    public Color showVertexColor = Color.white;
	public Color tempColor = Color.white;
    void DrawVertexPoints(PaintingObject j, Vector3 point)
    {
        if (j.renderer == null)
        {
            return;
        }
        var mtx = j.renderer.transform.localToWorldMatrix;
        point = j.renderer.transform.worldToLocalMatrix.MultiplyPoint3x4(point);
        float scale = 1.0f / Mathf.Abs(j.renderer.transform.lossyScale.x);
        float bz = scale * brushSize;
        bz *= bz;

        bool affected = false;
        for (int i = 0; i < j.verts.Length; ++i)
        {
            var p = j.verts[i];
            float x = point.x - p.x;
            float y = point.y - p.y;
            float z = point.z - p.z;
            float dist = x * x + y * y + z * z;

            if (dist < bz)
            {
                if (showPoint)
                {
                    Handles.color = showVertexColor;
                    if (j.stream.colors != null && j.stream.colors.Length == j.verts.Length)
                    {
                        Handles.color = j.stream.colors[i];
                        switch (brushChannel)
                        {
                            case BrushChannel.all:
                                Handles.color = j.stream.colors[i];
                                break;
                            case BrushChannel.red:
                                tempColor = Color.red * j.stream.colors[i].r;
                                tempColor.a = 1.0f;
                                Handles.color = tempColor;
                                break;
                            case BrushChannel.green:
                                tempColor = Color.green * j.stream.colors[i].g;
                                tempColor.a = 1.0f;
                                Handles.color = tempColor;
                                break;
                            case BrushChannel.blue:
                                tempColor = Color.blue * j.stream.colors[i].b;
                                tempColor.a = 1.0f;
                                Handles.color = tempColor;
                                break;
                            case BrushChannel.alpha:
                                tempColor = Color.white * j.stream.colors[i].a;
                                tempColor.a = 1.0f;
                                Handles.color = tempColor;
                                break;
                        }
                    }
                    Vector3 wp = mtx.MultiplyPoint(j.verts[i]);
                    //Handles.SphereHandleCap(0, wp, Quaternion.identity, HandleUtility.GetHandleSize(wp) * 0.06f, EventType.Repaint);
                    Handles.DotHandleCap(0, wp, Quaternion.identity, HandleUtility.GetHandleSize(wp) * 0.03f, EventType.Repaint);
                }

                if (drag)
                {
                    float pressure = Event.current.pressure > 0 ? Event.current.pressure : 1.0f;

                    float str = 1.0f - dist / bz;
                    str = Mathf.Pow(str, brushFalloff);
                    float finalStr = str * Time.deltaTime * (brushFlow / 8) * pressure;
                    if (finalStr > 0)
                    {
                        affected = true;
                        ColorRGBA(j, i, brushChannel, finalStr);
                        //ColorRGBA(j, i, ref brushColor, finalStr);
                    }
                }
            }
            if(fill)
            {
                affected = true;
                ColorRGBA(j, i, brushChannel, 1);
            }
        }
        if (fill)
            fill = false;
        if (affected)
        {
            j.stream.Apply();
        }
    }

    public void InitColors(PaintingObject j)
    {
        if (j.stream.colors == null || j.stream.colors.Length != j.verts.Length)
        {
            Color[] orig = j.meshFilter.sharedMesh.colors;
            if (j.meshFilter.sharedMesh.colors != null && j.meshFilter.sharedMesh.colors.Length > 0)
            {
                j.stream.colors = orig;
            }
            else
            {
                j.stream.SetColor(Color.white, j.verts.Length);
            }
        }
    }

    void ColorRGBA(PaintingObject j, int idx, ref Color v, float r)
    {
        var s = j.stream;
        s.colors[idx] = Color.Lerp(s.colors[idx], v, r);
    }
	void ColorRGBA(PaintingObject j, int idx,BrushChannel brushChannel, float r)
	{
		var s = j.stream;
		//s.colors[idx] = Color.Lerp(s.colors[idx], v, r);
		switch (brushChannel)
		{
			case BrushChannel.all:
				s.colors[idx] = Color.Lerp(s.colors[idx], currentBrushColor, r);
			break;
			case BrushChannel.red:
				brushColor = s.colors[idx];
				brushColor.r = currentBrushStrengh;
                if (is_weightmode)
                {
                    brushColor.g = 1.0f - brushColor.r;
                    brushColor.b = 1.0f - brushColor.r;
                    brushColor.a = 1.0f - brushColor.r;
                }
                s.colors[idx] = Color.Lerp(s.colors[idx], brushColor, r);
			break;
			case BrushChannel.green:
				brushColor = s.colors[idx];
				brushColor.g = currentBrushStrengh;
                if (is_weightmode)
                {
                    brushColor.r = 1.0f - brushColor.g;
                    brushColor.b = 1.0f - brushColor.g;
                    brushColor.a = 1.0f - brushColor.g;
                }
				s.colors[idx] = Color.Lerp(s.colors[idx], brushColor, r);
			break;
			case BrushChannel.blue:
				brushColor = s.colors[idx];
				brushColor.b = currentBrushStrengh;
                if (is_weightmode)
                {
                    brushColor.r = 1.0f - brushColor.b;
                    brushColor.g = 1.0f - brushColor.b;
                    brushColor.a = 1.0f - brushColor.b;
                }
                s.colors[idx] = Color.Lerp(s.colors[idx], brushColor, r);
			break;
			case BrushChannel.alpha:
				brushColor = s.colors[idx];
				brushColor.a = currentBrushStrengh;
                if (is_weightmode)
                {
                    brushColor.r = 1.0f - brushColor.a;
                    brushColor.g = 1.0f - brushColor.a;
                    brushColor.b = 1.0f - brushColor.a;
                }
                s.colors[idx] = Color.Lerp(s.colors[idx], brushColor, r);
			break;
		}
	}

    void OnUndo()
    {
        for (int i = 0; i < jobs.Length; ++i)
        {
            if (jobs[i].stream != null)
            {
                jobs[i].stream.Apply(false);
            }
        }
    }

    void EndStroke()
    {
        painting = false;

        for (int i = 0; i < jobs.Length; ++i)
        {
            PaintingObject j = jobs[i];
            if (j.HasStream())
            {
                EditorUtility.SetDirty(j.stream);
                EditorUtility.SetDirty(j.stream.gameObject);
            }
        }
    }

    void OnFocus()
    {
#if UNITY_2019_1_OR_NEWER
        SceneView.duringSceneGui -= this.OnSceneGUI;
        SceneView.duringSceneGui += this.OnSceneGUI;
#else
        SceneView.onSceneGUIDelegate -= this.OnSceneGUI;
        SceneView.onSceneGUIDelegate += this.OnSceneGUI;
#endif

        Undo.undoRedoPerformed -= this.OnUndo;
        Undo.undoRedoPerformed += this.OnUndo;
        Repaint();
    }

    void OnInspectorUpdate()
    {
        Repaint();
    }

    void OnSelectionChange()
    {
        InitMeshes();
        this.Repaint();
    }

    void OnDestroy()
    {
		if(EditorUtility.DisplayDialog("保存","退出编辑器会丢失数据，请确认是否需要保存","保存","取消"))
		{
			ExportPaintingData();
		}
		foreach(var obj in jobs)
		{
			obj.RevertMesh();
		}
        SceneView.onSceneGUIDelegate -= this.OnSceneGUI;
        Undo.undoRedoPerformed -= this.OnUndo;
    }
}