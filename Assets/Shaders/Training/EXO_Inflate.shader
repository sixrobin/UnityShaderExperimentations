Shader "EXO/EXO_Inflate"
{
    Properties
    {
        [Toggle]
        _NormalizeNormal ("Normalize Normal", float) = 0
        _InflateAmount ("Inflate Amount", Range(0, 1)) = 0
        _InflateSpeed ("Inflate Speed", Range(0, 100)) = 0
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
            #pragma multi_compile_fog
            #pragma shader_feature _NORMALIZENORMAL_ON

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL0;
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL0;
            };

            float _InflateAmount;
            float _InflateSpeed;
            
            v2f vert(appdata v)
            {
                v2f o;
                
                o.normal = v.normal;
                
                o.vertex = v.vertex;
                o.vertex.xyz += o.normal.xyz * ((1 + sin(_Time.y * _InflateSpeed)) * _InflateAmount);
                o.vertex = UnityObjectToClipPos(o.vertex);
                
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 normal = float3(0, 0, 0);
                #if _NORMALIZENORMAL_ON
                    normal = i.normal * 0.5 + 0.5;
                #else
                    normal = i.normal;
                #endif
                
                return float4(normal, 0);
            }
            ENDCG
        }
    }
}