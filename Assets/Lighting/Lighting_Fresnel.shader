Shader "Lighting/Fresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FresnelPower ("Fresnel Power", Range(1, 10)) = 1
        _FresnelColor ("Fresnel Color", Color) = (1,1,1,1)
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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv           : TEXCOORD0;
                float4 vertex       : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _FresnelPower;
            fixed4 _FresnelColor;

            float compute_fresnel(float3 normal, float3 vertex_world, float power)
            {
                return pow(1 - saturate(dot(normalize(normal), normalize(_WorldSpaceCameraPos - vertex_world))), power);
            }
            
            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            
            fixed4 frag(v2f i) : SV_Target
            {
                float4 col = tex2D(_MainTex, i.uv);
                float3 fresnel = float4(compute_fresnel(i.normal_world, i.vertex_world, _FresnelPower).xxx, 1);
                col.rgb += fresnel * _FresnelColor * _FresnelColor.a;
                return col;
            }
            
            ENDCG
        }
    }
}
