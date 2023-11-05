Shader "DM/DM_Test_Dither"
{
    Properties
    {
        _Size ("Size", float) = 1
        _Step ("Step", Range(0, 1)) = 0.5
        _ColorA ("Color A", Color) = (1, 1, 1, 1)
        _ColorB ("Color B", Color) = (0, 0, 0, 1)
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
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

            half _Size;
            half _Step;
            float4 _ColorA;
            float4 _ColorB;

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
            
            v2f vert (appdata v)
            {
                v2f o;
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screen_space = ComputeScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv_pixelated = floor((i.uv - 1/16.0) * 16) / 16;
                
                float4 dithering = dither(i.uv / _Size);
                dithering = step(_Step, dithering);
                // dithering = step(i.uv.y, dithering); // Upward dithering.

                return lerp(_ColorA, _ColorB, dithering);
            }
            
            ENDCG
        }
    }
}
