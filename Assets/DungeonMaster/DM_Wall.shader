Shader "DM/DM_Wall"
{
    Properties
    {
        [Header(GENERAL)]
        [Space(5)]
        _MainTex ("Texture", 2D) = "white" {}
        
        [Space(5)]
        [Header(DITHERED GRADIENT)]
        [Space(5)]
        _DitherSize ("Dither Size", Range(8, 32)) = 16
        _GradientScale ("Gradient Scale", Range(0, 1)) = 1
        _GradientColor ("Gradient Color", Color) = (0, 0, 0, 1)
        _GradientMask ("Gradient Mask", 2D) = "white" {}
        _GradientMaskStrength ("Gradient Mask Strength", Range(0, 1)) = 1
        
        [Space(5)]
        [Header(SCREEN DEPTH)]
        [Space(5)]
        _DepthColor ("Depth Color", Color) = (0, 0, 0, 1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }
        
        LOD 100

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
            };

            struct v2f
            {
                float2 uv           : TEXCOORD0;
                float4 vertex       : SV_POSITION;
                float4 screen_space : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _CameraDepthTexture;
            
            half _DitherSize;
            float _GradientScale;
            float4 _GradientColor;
            sampler2D _GradientMask;
            float4 _GradientMask_ST;
            float _GradientMaskStrength;
            
            uniform half _DepthMultiplier;
            uniform half _DepthSmoothCenter;
            uniform half _DepthSmoothValue;
            float4 _DepthColor;

            float4 dither(float2 uv)
            {
                uv *= 1080;
                
                float thresholds[16] =
                {
                    1 / 17.0,  9 / 17.0,  3 / 17.0,  11 / 17.0,
                    13 / 17.0, 5 / 17.0,  15 / 17.0, 7 / 17.0,
                    4 / 17.0,  12 / 17.0, 2 / 17.0,  10 / 17.0,
                    16 / 17.0, 8 / 17.0,  14 / 17.0, 6 / 17.0
                };
                
                uint index = (uint(uv.x) % 4) * 4 + uint(uv.y) % 4;
                return thresholds[index];
            }

            float3 contrast(float3 In, float contrast)
            {
                float midpoint = pow(0.5, 2.2);
                return (In - midpoint) * contrast + midpoint;
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.screen_space = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample textures.
                fixed4 main_color = tex2D(_MainTex, i.uv);
                fixed4 gradient_mask = tex2D(_GradientMask, i.uv);
                
                // Compute depth.
                float depth = i.screen_space.z;
                depth *= _DepthMultiplier;
                depth = smoothstep(_DepthSmoothCenter - _DepthSmoothValue, _DepthSmoothCenter + _DepthSmoothValue, depth);
                // depth = floor(depth * _PPU) / _PPU; // Pixelate depth test.
                
                // Dithered upward gradient.
                float4 dithering = dither(i.uv / _DitherSize);
                float4 dithering_gradient = step(i.uv.y / _GradientScale, dithering);
                dithering_gradient *= saturate(gradient_mask + (1 - _GradientMaskStrength));

                // Final color computation.
                return (main_color * (1 - dithering_gradient) + _GradientColor * dithering_gradient) * depth + (_DepthColor * (1 - depth));
            }
            
            ENDCG
        }
    }
}
