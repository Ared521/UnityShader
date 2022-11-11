using UnityEngine;
using System.Collections;
using UnityEditor;
using System;
using System.IO;

public class GenCamPngEditor : ScriptableWizard
{
    public int width = 1280, height = 720;
    public Camera cam = null;//Camera.main;
    static int wid = 0;
    static int hei = 0;
    [MenuItem("美术/小地图拍照工具",false,2001)]
    static void Generate()
    {
        wid = Screen.width;
        hei = Screen.height;

        ScriptableWizard.DisplayWizard("Generate Camera Png", typeof(GenCamPngEditor), "Generate");
    }

    void OnWizardUpdate()
    {
        helpString = "请填写分辨率";
        if (width != 0 && height != 0 && cam != null)
        {
            isValid = true;
        }
        else
        {
            isValid = false;
        }
    }

    void OnWizardCreate()
    {
        GenPng();
    }

    void GenPng()
    {
        
        //RenderTexture rt = new RenderTexture(width, height, 1, RenderTextureFormat.ARGB32);
        RenderTexture rt = new RenderTexture(width, height, 1);
        cam.targetTexture = rt;
        cam.Render();
        
        RenderTexture.active = rt;
        Texture2D screenShot = new Texture2D(width, height, TextureFormat.RGB24, false);
        screenShot.ReadPixels(new Rect(0, 0, width, height), 0, 0);// 注：这个时候，它是从RenderTexture.active中读取像素  
        screenShot.Apply();
        cam.targetTexture = null;
        RenderTexture.active = null;
        GameObject.DestroyImmediate(rt);


        byte[] bytes = screenShot.EncodeToPNG();
        string path = EditorUtility.OpenFolderPanel("Fold", "", "");
        string file_path = path;
        path += "/cam.png";
        System.IO.File.WriteAllBytes(path, bytes);
        Debug.Log(string.Format("Camera : {0} 截取完成: {1}", cam.name, path));
        AssetDatabase.Refresh();
    }

    public void WriteFileByLine(string file_path, string file_name, string str_info)
    {
        StreamWriter sw;
        if (!File.Exists(file_path + "//" + file_name))
        {
            sw = File.CreateText(file_path + "//" + file_name);//创建一个用于写入 UTF-8 编码的文本  
            Debug.Log("文件创建成功！");
        }
        else
        {
            sw = File.AppendText(file_path + "//" + file_name);//打开现有 UTF-8 编码文本文件以进行读取  
        }
        sw.WriteLine(str_info);//以行为单位写入字符串  
        sw.Close();
        sw.Dispose();//文件流释放  

    } 
}
