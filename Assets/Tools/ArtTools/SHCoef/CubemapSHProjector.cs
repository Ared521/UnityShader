using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class CubemapSHProjector : EditorWindow
{
    //PUBLIC FIELDS
    public Texture envMap;
    public Transform go;

    //PRIVATE FIELDS
    private Material    view_mat;
    private float       view_mode;
    private Vector4[]   coefficients;

    private SerializedObject so;
    private SerializedProperty sp_input_cubemap;

    private Texture2D tmp = null;

    private static void CheckAndConvertEnvMap(ref Texture envMap, ref Vector4[] sh_out)
    {
        if (!envMap) return;

        string map_path = AssetDatabase.GetAssetPath(envMap);

        if (string.IsNullOrEmpty(map_path)) return;

        TextureImporter ti = AssetImporter.GetAtPath(map_path) as TextureImporter;
        if (!ti) return;

        bool read_able = ti.isReadable;
        bool need_reimport = false;

        if (ti.textureShape != TextureImporterShape.TextureCube)
        {
            ti.textureShape = TextureImporterShape.TextureCube;
            need_reimport = true;
        }

        if (!ti.mipmapEnabled)
        {
            ti.mipmapEnabled = true;
            need_reimport = true;
        }

        if (!ti.sRGBTexture)
        {
            ti.sRGBTexture = true;
            need_reimport = true;
        }

        if (ti.filterMode != FilterMode.Trilinear)
        {
            ti.filterMode = FilterMode.Trilinear;
            need_reimport = true;
        }

        TextureImporterSettings tis = new TextureImporterSettings();
        ti.ReadTextureSettings(tis);
        if (tis.cubemapConvolution != TextureImporterCubemapConvolution.Specular)
        {
            tis.cubemapConvolution = TextureImporterCubemapConvolution.Specular;
            ti.SetTextureSettings(tis);
            need_reimport = true;
        }

        //if (ti.GetDefaultPlatformTextureSettings().maxTextureSize != 128)
        //{
        //    TextureImporterPlatformSettings tips = new TextureImporterPlatformSettings();
        //    tips.maxTextureSize = 128;
        //    ti.SetPlatformTextureSettings(tips);
        //    ti.maxTextureSize = 128;
        //    need_reimport = true;
        //}

        if (!read_able)
        {
            ti.isReadable = true;
            need_reimport = true;
        }

        if (need_reimport)
        {
            ti.SaveAndReimport();
        }

        envMap = AssetDatabase.LoadAssetAtPath<Texture>(map_path);
        if (!envMap) return;

        Vector3[] sh = new Vector3[9];
        SphericalHarmonicsCoefficient.sphericalHarmonicsFromCubemap9((Cubemap)envMap, ref sh);
        SphericalHarmonicsCoefficient.ConvertSHConstants(sh, ref sh_out);


        if (ti.isReadable != read_able)
        {
            ti.isReadable = read_able;
            ti.SaveAndReimport();
            envMap = AssetDatabase.LoadAssetAtPath<Texture>(map_path);
        }
    }

    [MenuItem("美术/SH系数生成", false, 2100)]
    static void Init()
    {
        CubemapSHProjector window = (CubemapSHProjector)EditorWindow.GetWindow(typeof(CubemapSHProjector));
        window.Show();
        window.titleContent = new GUIContent("SH生成器");
    }

    private void OnFocus()
    {
        Initialize();
    }

    private void OnEnable()
    {
        Initialize();
    }

    private void Initialize()
    {
        so = new SerializedObject(this);
        sp_input_cubemap = so.FindProperty("input_cubemap");
    }

    private void OnGUI()
    {
        EditorGUI.BeginChangeCheck();
        envMap = EditorGUILayout.ObjectField("环境图", envMap, typeof(Texture), false) as Texture;

        if (envMap != null)
        {
            EditorGUILayout.Space();

            if (GUILayout.Button("Calc"))
            {
                if (envMap != null)
                {
                    coefficients = new Vector4[7];
                    CheckAndConvertEnvMap(ref envMap, ref coefficients);
                }
                SceneView.RepaintAll();
            }

            EditorGUILayout.Space();

            go = EditorGUILayout.ObjectField("Obj", go, typeof(Transform), true) as Transform;
            if (go != null)
            {
                if (GUILayout.Button("Apply"))
                {
                    List<Material> mat_list = new List<Material>();
                    var renders = go.GetComponentsInChildren<Renderer>();
                    foreach (var render in renders)
                    {
                        mat_list.AddRange(render.sharedMaterials);
                    }
                    foreach (var mat in mat_list)
                    {
                        mat.SetVector("custom_SHAr", coefficients[0]);
                        mat.SetVector("custom_SHAg", coefficients[1]);
                        mat.SetVector("custom_SHAb", coefficients[2]);
                        mat.SetVector("custom_SHBr", coefficients[3]);
                        mat.SetVector("custom_SHBg", coefficients[4]);
                        mat.SetVector("custom_SHBb", coefficients[5]);
                        mat.SetVector("custom_SHC", coefficients[6]);
                    }
                    mat_list.Clear();
                    SceneView.RepaintAll();
                }
            }

            EditorGUILayout.Space();

            //print the 9 coefficients
            if (coefficients != null)
            {
                EditorGUILayout.LabelField("custom_SHAr" + ": " + coefficients[0].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHAg" + ": " + coefficients[1].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHAb" + ": " + coefficients[2].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHBr" + ": " + coefficients[3].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHBg" + ": " + coefficients[4].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHBb" + ": " + coefficients[5].ToString("F4"));
                EditorGUILayout.LabelField("custom_SHC" + ": " + coefficients[6].ToString("F4"));
            }
        }

        EditorGUILayout.Space();
        if (tmp != null)
            GUILayout.Label(tmp);
    }
}
