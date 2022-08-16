Shader "EXO/EXO_Sun"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ColorRamp ("Color Ramp", 2D) = "white" {}
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
                float2 uv_ramp : TEXCOORD1;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_ramp : TEXCOORD1;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _ColorRamp;
            float4 _ColorRamp_ST;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_ramp = TRANSFORM_TEX(v.uv, _ColorRamp);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 ramp = tex2D(_ColorRamp, float2(col.r, 0));

                return fixed4(ramp.rgb, 1);
            }
            
            ENDCG
        }
    }
}