using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class Postprocessing_UnderWater : MonoBehaviour
{
    //������ȡ������ɫ��ʽ�� StencilBuffer �Ĳ���
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
