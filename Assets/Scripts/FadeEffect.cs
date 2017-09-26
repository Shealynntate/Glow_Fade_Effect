using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeEffect : MonoBehaviour 
{
    public Material EffectMaterial;
    public RenderTexture RenderTexture;
 
    void Start()
    {
        // Clear the effect texture 
        Graphics.SetRenderTarget(RenderTexture);
        GL.Clear(false, true, new Color(0, 0, 0, 0));
    }

    void Update() 
    {
        Graphics.Blit(RenderTexture, RenderTexture, EffectMaterial);
    }
}

