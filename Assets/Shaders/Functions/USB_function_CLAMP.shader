Shader "USB/USB_function_CLAMP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ValueX ("X", Range(0, 1)) = 0
        _ValueA ("A", Range(0, 1)) = 0
        _ValueB ("B", Range(0, 1)) = 0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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
            float _ValueX;
            float _ValueA;
            float _ValueB;

            float customClamp(float a, float x, float b)
            {
                return max(a, min(x, b));
            }
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float darkness = customClamp(_ValueA, _ValueX, _ValueB);
                fixed4 col = tex2D(_MainTex, i.uv);
                col *= darkness;
                return col;
            }
            ENDCG
        }
    }
}
