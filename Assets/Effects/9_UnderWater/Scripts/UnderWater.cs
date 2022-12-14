using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UnderWater : MonoBehaviour
{
    //水面的位置

    public Transform water;

    //屏幕特效的材质

    public Material mat;

    //相机平面的法线和水面的法线

    private Vector3 nor_came, nor_water;

    //相机

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
        //两个平面的交线向量
        Vector3 nor1 = Vector3.Cross(nor_came, nor_water);
        //相机平面的法线向量和交线向量叉乘
        Vector3 nor2 = Vector3.Cross(nor_came, nor1);
        //相机近平面的上的中心点
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
