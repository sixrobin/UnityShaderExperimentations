Shader "Training/Plasma"
{
    Properties
    {
        _Scale ("Scale", float) = 1
        _ScaleHorizontal ("Scale Horizontal", float) = 1
        _ScaleVertical ("Scale Vertical", float) = 1
        _Speed ("Speed", float) = 1
        _RingsMultiplier ("Rings Multiplier", Range(0, 10)) = 1
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
                float2 uv     : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float _Scale;
            float _ScaleHorizontal;
            float _ScaleVertical;
            float _Speed;
            float _RingsMultiplier;
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float3 Plasma(float2 uv)
            {
                const float time = _Time.y * _Speed;

                uv = uv * _Scale - _Scale * 0.5;
                
                float wave1 = sin(uv.x + time) * _ScaleVertical;
                float wave2 = sin(uv.y + time) * _ScaleHorizontal;
                float wave3 = sin(uv.x + uv.y + time);

                float rings = sin(sqrt(uv.x * uv.x + uv.y * uv.y) + time);
                
                float final_value = wave1 + wave2 + wave3 + rings;

                const float rings_multiplier = final_value * UNITY_PI * _RingsMultiplier;
                float3 final_wave = float3(sin(rings_multiplier), cos(rings_multiplier), 0);
                final_wave = final_wave * 0.5 + 0.5;

                return final_wave;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                fixed3 plasma = Plasma(i.uv);
                return fixed4(plasma.rgb, 1);
            }
            
            ENDCG
        }
    }
}
