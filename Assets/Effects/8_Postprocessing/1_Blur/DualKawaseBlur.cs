using System;
using UnityEngine;
using System.Collections.Generic;

[RequireComponent(typeof(Camera))]
[ExecuteInEditMode]

public class DualKawaseBlur : MonoBehaviour
{

    public Material material;
    [Range(0,15)]
    public float _BlurRadius = 5.0f;
    [Range(0, 10)]
    public int _Iteration = 4;
    [Range(1, 10)]
    public float _DownSample = 2.0f;

    List<RenderTexture> _tempRTList = new List<RenderTexture>();

    void Start()
    {
        if (!SystemInfo.supportsImageEffects || null == material ||
           null == material.shader || !material.shader.isSupported)
        {
            enabled = false;
            return;
        }
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        int RTWidth = (int)(source.width / _DownSample);
        int RTHeight = (int)(source.height / _DownSample);
        RenderTexture RT1 = RenderTexture.GetTemporary(RTWidth, RTHeight, 0);
        RenderTexture RT2 = null;
        material.SetFloat("_Offset", _BlurRadius);
        Graphics.Blit(source, RT1, material, 0);

        for (int i = 0; i < _Iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            RTWidth = RTWidth / 2;
            RTHeight = RTHeight / 2;
            RT2 = RenderTexture.GetTemporary(RTWidth, RTHeight);
            Graphics.Blit(RT1, RT2, material, 0);

            RTWidth = RTWidth / 2;
            RTHeight = RTHeight / 2;
            RenderTexture.ReleaseTemporary(RT1);
            RT1 = RenderTexture.GetTemporary(RTWidth, RTHeight);
            Graphics.Blit(RT2, RT1, material, 0);
        }

        for (int i = 0; i < _Iteration; i++)
        {
            RenderTexture.ReleaseTemporary(RT2);
            RTWidth = RTWidth * 2;
            RTHeight = RTHeight * 2;
            RT2 = RenderTexture.GetTemporary(RTWidth, RTHeight);
            Graphics.Blit(RT1, RT2, material, 1);

            RTWidth = RTWidth * 2;
            RTHeight = RTHeight * 2;
            RenderTexture.ReleaseTemporary(RT1);
            RT1 = RenderTexture.GetTemporary(RTWidth, RTHeight);
            Graphics.Blit(RT2, RT1, material, 1);
        }

        Graphics.Blit(RT1, destination, material, 1);

        // release
        RenderTexture.ReleaseTemporary(RT1);
        RenderTexture.ReleaseTemporary(RT2);
    }
}