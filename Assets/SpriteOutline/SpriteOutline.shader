Shader "Sprites/Outline"
{
    Properties
    {
        _OutlineColor ("Outline Color", Color) = (1,1,1,1)

        [Space(30)]

        _OutlineThickness ("Outline Thickness", Float) = 1
        _OutlineIntensity ("Outline Intensity", Float) = 10
        _SampledMipLevel ("Sampled Mip Level", Int) = 0
        _AlphaClipSmoothMin ("Alpha Clip Smooth Min", Range(0, 1)) = 0
        _AlphaClipSmoothMax ("Alpha Clip Smooth Max", Range(0, 1)) = 1
        
        [Space(30)]
        
        _DistortionNoise ("Distortion Noise", 2D) = "white" {}
        _DistortionIntensity ("Distortion Intensity", Float) = 1

        [PerRendererData] [HideInInspector] _MainTex ("Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        [HideInInspector] _RendererColor ("RendererColor", Color) = (1,1,1,1)
        [HideInInspector] _Flip ("Flip", Vector) = (1,1,1,1)
        [PerRendererData] _AlphaTex ("External Alpha", 2D) = "white" {}
        [PerRendererData] _EnableExternalAlpha ("Enable External Alpha", Float) = 0
    }
    
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "IgnoreProjector"="True"
            "RenderType"="Transparent"
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }
        
        Cull Off
        Lighting Off
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex SpriteVert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile_local _ PIXELSNAP_ON
            #pragma multi_compile _ ETC1_EXTERNAL_ALPHA

            #include "UnityCG.cginc"
            #include "UnitySprites.cginc"

            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            float4 _OutlineColor;
            
            float _OutlineThickness;
            float _OutlineIntensity;
            int _SampledMipLevel;
            float _AlphaClipSmoothMin;
            float _AlphaClipSmoothMax;
            
            float _HeightFadeMin;
            float _HeightFadeMax;

            sampler2D _DistortionNoise;
            float4 _DistortionNoise_ST;
            float _DistortionIntensity;

            fixed4 frag(v2f i) : SV_Target
            {
                float stepW = _MainTex_TexelSize.x * _OutlineThickness;
                float stepH = _MainTex_TexelSize.y * _OutlineThickness;
         
                const float2 offset[25] =
                {
                    float2(-stepW * 2, -stepH * 2), float2(-stepW, -stepH * 2), float2(0, -stepH * 2), float2(stepW, -stepH * 2), float2(stepW * 2, -stepH * 2),
                    float2(-stepW * 2, -stepH),     float2(-stepW, -stepH),     float2(0, -stepH),     float2(stepW, -stepH),     float2(stepW * 2, -stepH),
                    float2(-stepW * 2, 0),          float2(-stepW, 0),          float2(0, 0),          float2(stepW, 0),          float2(stepW * 2, 0),
                    float2(-stepW * 2, stepH),      float2(-stepW, stepH),      float2(0, stepH),      float2(stepW, stepH),      float2(stepW * 2, stepH),
                    float2(-stepW * 2, stepH * 2),  float2(-stepW, stepH * 2),  float2(0, stepH * 2),  float2(stepW, stepH * 2),  float2(stepW * 2, stepH * 2),
                };

                const float kernel[25] =
                {
                    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
                    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
                    0.023792, 0.094907, 0.150342, 0.094907, 0.023792,
                    0.015019, 0.059912, 0.094907, 0.059912, 0.015019,
                    0.003765, 0.015019, 0.023792, 0.015019, 0.003765,
                };

                float4 mainColor = tex2D(_MainTex, i.texcoord) * i.color;

                float noiseSum = 0;
                [unroll]
                for (int j = 0; j < 25; j++)
                    noiseSum += tex2Dlod(_MainTex, float4(i.texcoord + offset[j], 0, _SampledMipLevel)).a * kernel[j];

                float distortion = lerp(1, tex2D(_DistortionNoise, i.texcoord * _DistortionNoise_ST.xy + _DistortionNoise_ST.zw * _Time.y).r, _DistortionIntensity);
                noiseSum *= distortion;
                noiseSum *= _OutlineIntensity;
                noiseSum *= smoothstep(_HeightFadeMin, _HeightFadeMax, i.texcoord.y);
                
                float4 outline = lerp(float4(_OutlineColor.rgb, 0), _OutlineColor, smoothstep(_AlphaClipSmoothMin, _AlphaClipSmoothMax, noiseSum));

                return lerp(outline, mainColor, mainColor.a);
            }
            
            ENDCG
        }
    }
}
