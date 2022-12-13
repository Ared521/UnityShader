using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Postprocessing_UnderWater : MonoBehaviour
{
    //用于提取出纯颜色形式的 StencilBuffer 的材质
    public Material postprocessing;

    public RenderTexture buffer;

    public void Start()
    {

    }
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        buffer = new RenderTexture(source.width, source.width, 24);
        
        Graphics.Blit(source, destination, postprocessing);
    }
}
