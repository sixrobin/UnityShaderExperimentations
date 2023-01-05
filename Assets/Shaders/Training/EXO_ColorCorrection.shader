Shader "EXO/EXO_ColorCorrection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _HueShift ("Hue Shift", Range(0, 6.283)) = 0 // 6.283 = TAU
        _Saturation ("Saturation", Range(0, 5)) = 1
        _Brightness ("Brightness", Range(-1, 1)) = 0
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _HueShift;
            float _Saturation;
            float _Brightness;

            float3 ColorCorrection(float3 color)
            {
                const float3x3 yiq_to_rgb = { +1.0000, +0.9563, +0.6210,
                                              +1.0000, -0.2721, -0.6474,
                                              +1.0000, -1.1070, +1.7046 };

                const float3x3 rgb_to_yiq = { +0.2990, +0.5870, +0.1140,
                                              +0.5957, -0.2745, -0.3213,
                                              +0.2115, -0.5226, +0.3112 };

                float3 yiq = mul(rgb_to_yiq, color);
                
                const float hue = atan2(yiq.z, yiq.y) + _HueShift;
                const float chroma = length(float2(yiq.y, yiq.z)) * _Saturation;

                float y = yiq.x + _Brightness;
                float i = chroma * cos(hue);
                float q = chroma * sin(hue);

                const float3 yiq_shift = float3(y, i, q);
                float3 rgb = mul(yiq_to_rgb, yiq_shift);
                
                return rgb;
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                col.rgb = ColorCorrection(col.rgb);
                return col;
            }
            
            ENDCG
        }
    }
}
