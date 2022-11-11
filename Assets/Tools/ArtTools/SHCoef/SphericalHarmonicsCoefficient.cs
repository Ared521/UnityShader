/// <summary>
/// 球谐光照因子计算方法,结果可以跟Unity内部的算法匹配上
/// http://sunandblackcat.com/tipFullView.php?l=eng&topicid=32&topic=Spherical-Harmonics-From-Cube-Texture
/// https://github.com/Microsoft/DirectXMath
/// http://www.ppsloan.org/publications/StupidSH36.pdf
/// </summary>

using UnityEngine;
using UnityEditor;

public static class SphericalHarmonicsCoefficient
{
    public static void sphericalHarmonicsFromCubemap9(Cubemap cubeTexture, ref Vector3[] output)
    {
        // allocate memory for calculations
        float[] resultR = new float[9];
        float[] resultG = new float[9];
        float[] resultB = new float[9];

        // initialize values
        float fWt = 0.0f;
        for (uint i = 0; i < 9; i++)
        {
            resultR[i] = 0;
            resultG[i] = 0;
            resultB[i] = 0;
        }

        float[] shBuff = new float[9];
        float[] shBuffB = new float[9];

        // for each face of cube texture
        for (int face = 0; face < 6; face++)
        {
            // step between two texels for range [0, 1]
            float invWidth = 1.0f / cubeTexture.width;
            // initial negative bound for range [-1, 1]
            float negativeBound = -1.0f + invWidth;
            // step between two texels for range [-1, 1]
            float invWidthBy2 = 2.0f / cubeTexture.width;

            Color[] data = cubeTexture.GetPixels((CubemapFace)face);

            for (int y = 0; y < cubeTexture.width; y++)
            {
                // texture coordinate V in range [-1 to 1]
                float fV = negativeBound + y * invWidthBy2;

                for (int x = 0; x < cubeTexture.width; x++)
                {
                    // texture coordinate U in range [-1 to 1]
                    float fU = negativeBound + x * invWidthBy2;

                    // determine direction from center of cube texture to current texel
                    Vector3 dir;

                    switch ((CubemapFace)face)
                    {
                        case CubemapFace.PositiveX:
                            dir.x = 1.0f;
                            dir.y = 1.0f - (invWidthBy2 * y + invWidth);
                            dir.z = 1.0f - (invWidthBy2 * x + invWidth);
                            break;
                        case CubemapFace.NegativeX:
                            dir.x = -1.0f;
                            dir.y = 1.0f - (invWidthBy2 * y + invWidth);
                            dir.z = -1.0f + (invWidthBy2 * x + invWidth);
                            break;
                        case CubemapFace.PositiveY:
                            dir.x = -1.0f + (invWidthBy2 * x + invWidth);
                            dir.y = 1.0f;
                            dir.z = -1.0f + (invWidthBy2 * y + invWidth);
                            break;
                        case CubemapFace.NegativeY:
                            dir.x = -1.0f + (invWidthBy2 * x + invWidth);
                            dir.y = -1.0f;
                            dir.z = 1.0f - (invWidthBy2 * y + invWidth);
                            break;
                        case CubemapFace.PositiveZ:
                            dir.x = -1.0f + (invWidthBy2 * x + invWidth);
                            dir.y = 1.0f - (invWidthBy2 * y + invWidth);
                            dir.z = 1.0f;
                            break;
                        case CubemapFace.NegativeZ:
                            dir.x = 1.0f - (invWidthBy2 * x + invWidth);
                            dir.y = 1.0f - (invWidthBy2 * y + invWidth);
                            dir.z = -1.0f;
                            break;
                        default:
                            return;
                    }

                    // normalize direction
                    dir = dir.normalized;

                    // scale factor depending on distance from center of the face
                    float fDiffSolid = 4.0f / ((1.0f + fU * fU + fV * fV) * Mathf.Sqrt(1.0f + fU * fU + fV * fV));
                    fWt += fDiffSolid;

                    // calculate coefficients of spherical harmonics for current direction
                    sphericalHarmonicsEvaluateDirection9(ref shBuff, dir);
                    //XMSHEvalDirection(dir, ref shBuff);

                    // index of texel in texture
                    int pixOffsetIndex = x + y * cubeTexture.width;
                    // get color from texture and map to range [0, 1]
                    Vector3 clr= new Vector3(data[pixOffsetIndex].r, data[pixOffsetIndex].g, data[pixOffsetIndex].b);
                    //if (data[pixOffsetIndex].a == 1)
                    //{
                    //    clr = new Vector3(data[pixOffsetIndex].r, data[pixOffsetIndex].g, data[pixOffsetIndex].b);
                    //}
                    //else
                    //{
                    //    clr = DecodeHDR(data[pixOffsetIndex]);
                    //}
                    if (PlayerSettings.colorSpace == ColorSpace.Gamma)
                    {
                        clr.x = Mathf.GammaToLinearSpace(clr.x);
                        clr.y = Mathf.GammaToLinearSpace(clr.y);
                        clr.z = Mathf.GammaToLinearSpace(clr.z);
                    }
                    // scale color and add to previously accumulated coefficients
                    sphericalHarmonicsScale9(ref shBuffB, shBuff, clr.x * fDiffSolid);
                    sphericalHarmonicsAdd9(ref resultR, resultR, shBuffB);
                    sphericalHarmonicsScale9(ref shBuffB, shBuff, clr.y * fDiffSolid);
                    sphericalHarmonicsAdd9(ref resultG, resultG, shBuffB);
                    sphericalHarmonicsScale9(ref shBuffB, shBuff, clr.z * fDiffSolid);
                    sphericalHarmonicsAdd9(ref resultB, resultB, shBuffB);
                }
            }
        }

        // final scale for coefficients
        float fNormProj = (4.0f * Mathf.PI) / fWt;
        sphericalHarmonicsScale9(ref resultR, resultR, fNormProj);
        sphericalHarmonicsScale9(ref resultG, resultG, fNormProj);
        sphericalHarmonicsScale9(ref resultB, resultB, fNormProj);

        // save result
        for (uint i = 0; i < 9; i++)
        {
            output[i].x = resultR[i];
            output[i].y = resultG[i];
            output[i].z = resultB[i];
        }
    }

    private static Vector3 DecodeHDR(Color clr)
    {
        return new Vector3(clr.r, clr.g, clr.b) * clr.a;// * Mathf.Pow(clr.a, 2);// * (Mathf.Pow(clr.a, 0.1f) * 1);
    }

    private static void sphericalHarmonicsEvaluateDirection9(ref float[] outsh, Vector3 dir)
    {
        // 86 clocks
        // Make sure all constants are never computed at runtime
        const float kInv2SqrtPI = 0.28209479177387814347403972578039f; // 1 / (2*sqrt(kPI))
        const float kSqrt3Div2SqrtPI = 0.48860251190291992158638462283835f; // sqrt(3) / (2*sqrt(kPI))
        const float kSqrt15Div2SqrtPI = 1.0925484305920790705433857058027f; // sqrt(15) / (2*sqrt(kPI))
        const float k3Sqrt5Div4SqrtPI = 0.94617469575756001809268107088713f; // 3 * sqrtf(5) / (4*sqrt(kPI))
        const float kSqrt15Div4SqrtPI = 0.54627421529603953527169285290135f; // sqrt(15) / (4*sqrt(kPI))
        const float kOneThird = 0.3333333333333333333333f; // 1.0/3.0
        outsh[0] = kInv2SqrtPI;
        outsh[1] = -dir.y * kSqrt3Div2SqrtPI;
        outsh[2] = dir.z * kSqrt3Div2SqrtPI;
        outsh[3] = -dir.x * kSqrt3Div2SqrtPI;
        outsh[4] = dir.x * dir.y * kSqrt15Div2SqrtPI;
        outsh[5] = -dir.y * dir.z * kSqrt15Div2SqrtPI;
        outsh[6] = (dir.z * dir.z - kOneThird) * k3Sqrt5Div4SqrtPI;
        outsh[7] = -dir.x * dir.z * kSqrt15Div2SqrtPI;
        outsh[8] = (dir.x * dir.x - dir.y * dir.y) * kSqrt15Div4SqrtPI;
    }

    private static void sphericalHarmonicsAdd9(ref float[] result, float[] inputA, float[] inputB)
    {
        for (int i = 0; i < 9; i++)
        {
            result[i] = inputA[i] + inputB[i];
        }
    }

    private static void sphericalHarmonicsScale9(ref float[] result, float[] input, float scale)
    {
        for (int i = 0; i < 9; i++)
        {
            result[i] = input[i] * scale;
        }
    }

    public static readonly float s_fSqrtPI = Mathf.Sqrt(Mathf.PI);
    public static readonly float fC0 = 1.0f / (2.0f * s_fSqrtPI);
    public static readonly float fC1 = Mathf.Sqrt(3.0f) / (3.0f * s_fSqrtPI);
    public static readonly float fC2 = Mathf.Sqrt(15.0f) / (8.0f * s_fSqrtPI);
    public static readonly float fC3 = Mathf.Sqrt(5.0f) / (16.0f * s_fSqrtPI);
    public static readonly float fC4 = 0.5f * fC2;
    public static void ConvertSHConstants(Vector3[] sh, ref Vector4[] SHArBrC)
    {
        int iC;
        for (iC = 0; iC < 3; iC++)
        {
            SHArBrC[iC].x = -fC1 * sh[3][iC];
            SHArBrC[iC].y = -fC1 * sh[1][iC];
            SHArBrC[iC].z = fC1 * sh[2][iC];
            SHArBrC[iC].w = fC0 * sh[0][iC] - fC3 * sh[6][iC];
        }

        for (iC = 0; iC < 3; iC++)
        {
            SHArBrC[iC + 3].x = fC2 * sh[4][iC];
            SHArBrC[iC + 3].y = -fC2 * sh[5][iC];
            SHArBrC[iC + 3].z = 3.0f * fC3 * sh[6][iC];
            SHArBrC[iC + 3].w = -fC2 * sh[7][iC];
        }

        SHArBrC[6].x = fC4 * sh[8][0];
        SHArBrC[6].y = fC4 * sh[8][1];
        SHArBrC[6].z = fC4 * sh[8][2];
        SHArBrC[6].w = 1.0f;
    }
}