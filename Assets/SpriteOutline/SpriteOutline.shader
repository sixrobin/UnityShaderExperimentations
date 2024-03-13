Shader "Sprites/Outline"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)

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
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        
        Pass
        {
            CGPROGRAM
            
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv     : TEXCOORD0;
                float4 color  : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv     : TEXCOORD0;
                float4 color  : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainTex_TexelSize;

            float4 _Color;
            
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

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

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

                float4 mainColor = tex2D(_MainTex, i.uv) * i.color;

                float noiseSum = 0;
                [unroll]
                for (int j = 0; j < 25; j++)
                    noiseSum += tex2Dlod(_MainTex, float4(i.uv + offset[j], 0, _SampledMipLevel)).a * kernel[j];

                float distortion = lerp(1, tex2D(_DistortionNoise, i.uv * _DistortionNoise_ST.xy + _DistortionNoise_ST.zw * _Time.y).r, _DistortionIntensity);
                noiseSum *= distortion;
                noiseSum *= _OutlineIntensity;
                noiseSum *= smoothstep(_HeightFadeMin, _HeightFadeMax, i.uv.y);
                
                float4 outline = lerp(float4(_Color.rgb, 0), _Color, smoothstep(_AlphaClipSmoothMin, _AlphaClipSmoothMax, noiseSum));

                return lerp(outline, mainColor, mainColor.a);
            }
            
            ENDCG
        }
    }
}
