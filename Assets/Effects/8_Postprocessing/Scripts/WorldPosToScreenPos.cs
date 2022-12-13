using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WorldPosToScreenPos : MonoBehaviour
{
    public Camera myCamera;
    public Transform waterPlane;
    public Vector3 screenPos;



    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        screenPos = myCamera.WorldToScreenPoint(waterPlane.position);


    }


}
