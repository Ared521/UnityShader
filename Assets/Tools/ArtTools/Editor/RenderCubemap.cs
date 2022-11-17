using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using System.IO;
using UnityEngine.Rendering;


public class RenderCubemap : EditorWindow {
    public enum GenMode {
        SingleCubemap = 0,
        SixTextures
    }


    private static string[] _names = new string[] { "16", "32", "64", "128", "256", "512", "1024", "2048" };
    private static int[] _sizes = new int[] { 16, 32, 64, 128, 256, 512, 1024, 2048 };

    private static Vector3[] _cameraAngles = new Vector3[] {
        new Vector3(0, 90, 0), new Vector3(0, -90, 0),
        new Vector3(-90, 0, 0), new Vector3(90, 0, 0),
        new Vector3(0, 0, 0), new Vector3(0, 180, 0),
    };

    private static string[] _filePostfixs = new string[] {
        "_Left", "_Right", "_Up", "_Down", "_Front", "_Back"
    };

    private GenMode _genMode;
    private int _selectedSize = 1024;
    private int _lastSelectedSize;
    private RenderTexture[] _rtexs;
    private Texture2D[] _colorTexs;
    private Transform _center;
    [SerializeField]
    private LayerMask _layerMask = -1;
    SerializedObject serializedObject;

    void OnEnable() {
        titleContent = new GUIContent("RenderCubemap");
        serializedObject = new UnityEditor.SerializedObject(this);
    }

    void OnDestroy() {
        DestroyResources();
    }

    void CreateResources() {
        _rtexs = new RenderTexture[6];
        for (int i = 0; i < 6; i++) {
            _rtexs[i] = new RenderTexture(_selectedSize, _selectedSize, 24);
            _rtexs[i].hideFlags = HideFlags.HideAndDontSave;
        }

        _colorTexs = new Texture2D[6];
        for (int i = 0; i < 6; i++)
            _colorTexs[i] = new Texture2D(_selectedSize, _selectedSize, TextureFormat.RGB24, false);
    }

    void DestroyResources() {
        if (_rtexs != null) {
            for (int i = 0; i < 6; i++)
                DestroyImmediate(_rtexs[i]);
            _rtexs = null;
        }

        if (_colorTexs != null) {
            for (int i = 0; i < 6; i++) {
                DestroyImmediate(_colorTexs[i]);
            }
        }
    }


    void OnGUI() {

        GUILayout.Space(5);

        EditorGUI.BeginChangeCheck();
        _genMode = (GenMode)EditorGUILayout.EnumPopup("Mode", _genMode);
        _selectedSize = EditorGUILayout.IntPopup("Face Size", _selectedSize, _names, _sizes);
        _center = EditorGUILayout.ObjectField("Center", _center, typeof(Transform), true) as Transform;
        EditorGUILayout.PropertyField(serializedObject.FindProperty("_layerMask"));

        GUILayout.Space(15);

        bool hasError = false;
        Color oldContentColor = GUI.contentColor;
        GUI.contentColor = Color.red;
        if (_center == null) {
            GUILayout.Label("必须设置'Center'!");
            hasError = true;
        }
        Camera mainCam = Camera.main;
        if (mainCam == null) {
            GUI.contentColor = Color.red;
            GUILayout.Label("场景中必须有Main Camera!");
            hasError = true;
        }
        GUI.contentColor = oldContentColor;

        if (hasError) {
            return;
        }


        // _layerMask = EditorToolUtility.LayerMaskField("Culling Mask", _layerMask);
        GUILayout.Space(15);

        EditorGUILayout.BeginHorizontal();
        GUILayout.FlexibleSpace();
        if (GUILayout.Button("Bake", GUILayout.Width(100))) {
            if (_rtexs == null || _selectedSize != _lastSelectedSize) {
                DestroyResources();
                CreateResources();
                _lastSelectedSize = _selectedSize;
            }


            GameObject go = GameObject.Instantiate(mainCam.gameObject);
            go.name = "__CubemapCamera__";
            Camera cam = go.GetComponent<Camera>();
            cam.enabled = false;
            cam.backgroundColor = Camera.main.backgroundColor;
            cam.aspect = 1;
            cam.fieldOfView = 90;
            cam.cullingMask = _layerMask;

            go.transform.position = _center.position;

            RenderTexture oldRt = RenderTexture.active;
            for (int i = 0; i < 6; i++) {
                go.transform.localEulerAngles = _cameraAngles[i];

                RenderTexture.active = _rtexs[i];
                cam.targetTexture = _rtexs[i];
                cam.Render();

                _colorTexs[i].ReadPixels(new Rect(0, 0, _selectedSize, _selectedSize), 0, 0);
                _colorTexs[i].Apply();
            }


            RenderTexture.active = oldRt;
            DestroyImmediate(go);

            Texture2D tex = WriteAndImportTexture();
            if (tex != null)
                Debug.Log("渲染到环境贴图完成！", tex);
        }
        EditorGUILayout.EndHorizontal();
    }
        
    private Texture2D WriteAndImportTexture() {
        if (_genMode == GenMode.SingleCubemap) {
            string path = EditorUtility.SaveFilePanelInProject("Save Cubemap", "", "png", "Please enter a file name to save cubemap to");
            if (!string.IsNullOrEmpty(path)) {
                Texture2D cubeTex = new Texture2D(_selectedSize * 4, _selectedSize * 3, TextureFormat.RGB24, false);

                Color[] colors = _colorTexs[0].GetPixels();
                cubeTex.SetPixels(_selectedSize * 2, _selectedSize, _selectedSize, _selectedSize, colors);
                colors = _colorTexs[1].GetPixels();
                cubeTex.SetPixels(0, _selectedSize, _selectedSize, _selectedSize, colors);
                colors = _colorTexs[2].GetPixels();
                cubeTex.SetPixels(_selectedSize, _selectedSize * 2, _selectedSize, _selectedSize, colors);
                colors = _colorTexs[3].GetPixels();
                cubeTex.SetPixels(_selectedSize, 0, _selectedSize, _selectedSize, colors);
                colors = _colorTexs[4].GetPixels();
                cubeTex.SetPixels(_selectedSize, _selectedSize, _selectedSize, _selectedSize, colors);
                colors = _colorTexs[5].GetPixels();
                cubeTex.SetPixels(_selectedSize * 3, _selectedSize, _selectedSize, _selectedSize, colors);

                cubeTex.Apply();
                byte[] bytes = cubeTex.EncodeToPNG();
                File.WriteAllBytes(path, bytes);
                AssetDatabase.ImportAsset(path);
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                importer.textureShape = TextureImporterShape.TextureCube;
                importer.generateCubemap = TextureImporterGenerateCubemap.AutoCubemap;
                importer.maxTextureSize = _selectedSize;
                AssetDatabase.ImportAsset(path, ImportAssetOptions.ForceUpdate);
                cubeTex = AssetDatabase.LoadAssetAtPath(path, typeof(Texture2D)) as Texture2D;

                return cubeTex;
            }
            return null;

        } else if (_genMode == GenMode.SixTextures) {
            string path = EditorUtility.SaveFilePanelInProject("Save Textures", "", "png", "Please enter a file name to save textures to");
            if (!string.IsNullOrEmpty(path)) {
                //Material material = new Material(Shader.Find("Skybox/6 Sided"));
                //AssetDatabase.CreateAsset(material, path);

                string header = path.Substring(0, path.Length - 4);
                for (int i = 0; i < 6; i++) {
                    if (header.EndsWith(_filePostfixs[i])) {
                        header = header.Substring(0, header.Length - _filePostfixs[i].Length);
                        break;
                    }
                }

                Texture2D[] newTextures = new Texture2D[6];
                for (int i = 0; i < 6; i++) {
                    string outPath = header + _filePostfixs[i] + ".png";

                    byte[] bytes = _colorTexs[i].EncodeToPNG();
                    File.WriteAllBytes(outPath, bytes);

                    AssetDatabase.ImportAsset(outPath);
                    TextureImporter importer = AssetImporter.GetAtPath(outPath) as TextureImporter;
                    importer.textureType = TextureImporterType.Default;
                    importer.wrapMode = TextureWrapMode.Clamp;
                    importer.maxTextureSize = _selectedSize;
                    AssetDatabase.ImportAsset(outPath, ImportAssetOptions.ForceUpdate);

                    newTextures[i] = AssetDatabase.LoadAssetAtPath(outPath, typeof(Texture2D)) as Texture2D;
                }

                return newTextures[0];
            }
        }

        return null;
    }


    [MenuItem("美术/渲染到环境贴图...", false, 5000)]
    private static void Init() {
        RenderCubemap editWindow = ScriptableObject.CreateInstance<RenderCubemap>();
        editWindow.Show();
    }
}
