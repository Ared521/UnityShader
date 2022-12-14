using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnderWater : MonoBehaviour
{
    //ˮ���λ��

    public Transform water;

    //��Ļ��Ч�Ĳ���

    public Material mat;

    //���ƽ��ķ��ߺ�ˮ��ķ���

    private Vector3 nor_came, nor_water;

    //���

    private Camera main;
    Vector3 pos;

    void Start()
    {
        main = transform.GetComponent<Camera>();
        main.depthTextureMode = DepthTextureMode.DepthNormals;
    }


    void Update()
    {
        nor_came = transform.forward;
        nor_water = water.up;
        //����ƽ��Ľ�������
        Vector3 nor1 = Vector3.Cross(nor_came, nor_water);
        //���ƽ��ķ��������ͽ����������
        Vector3 nor2 = Vector3.Cross(nor_came, nor1);
        //�����ƽ����ϵ����ĵ�
        Vector3 cam_plane_pos = transform.position + transform.forward * main.nearClipPlane;
        Vector3 p = cam_plane_pos - water.position;
        float d = -Vector3.Dot(p, water.up) / Vector3.Dot(nor2, water.up);
        pos = main.WorldToScreenPoint(cam_plane_pos + nor2 * d);
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_Posy", pos.y);
        Graphics.Blit(source, destination, mat);
    }
}
