/********************************************************************
 FileName: GodRayVolumeHelper.cs
 Description:
 Created: 2018/04/20
 history: 20:4:2018 0:24 by zhangjian
*********************************************************************/
using UnityEngine;
 
[ExecuteInEditMode]
public class GodRayVolumeHelper : MonoBehaviour {
 
    public Transform lightTransform;
    private Material godRayVolumeMateril;
 
    void Awake()
    {
        var renderer = GetComponentInChildren<Renderer>();
        foreach(var mat in renderer.sharedMaterials)
        {
            if (mat.shader.name.Contains("VolumeShadow"))
                godRayVolumeMateril = mat;
        }
    }
	
	// Update is called once per frame
	void Update ()
    {
        if (lightTransform == null || godRayVolumeMateril == null)
            return;
        float distance = Vector3.Distance(lightTransform.position, transform.position);
        godRayVolumeMateril.SetVector("_WorldLightPos", new Vector4(lightTransform.position.x, lightTransform.position.y, lightTransform.position.z, distance));
    }
}