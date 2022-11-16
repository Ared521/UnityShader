Shader "FengLL_Book/Chapter3/UsePass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        UsePass "FengLL_Book/Chapter3/TwoPass/Pass1"
    }
}
