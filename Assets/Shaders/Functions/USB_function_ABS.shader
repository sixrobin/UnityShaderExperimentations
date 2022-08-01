Shader "USB/USB_function_ABS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        
        [Header(Kaleidoscope)]
        [Space(10)]
        _Rotation ("Rotation", Range(0, 360)) = 0
        _Center ("Center", float) = 0.5
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
            float _Rotation;
            float _Center;
            
            void rotateDegrees_float(float2 uv, float2 center, float rotation, out float2 result)
            {
                rotation = rotation * (UNITY_PI / 180.0f);
                uv -= center;
                float s = sin(rotation);
                float c = cos(rotation);

                float2x2 rMatrix = float2x2(c, -s, s, c);
                rMatrix *= 0.5f;
                rMatrix += 0.5f;
                rMatrix = rMatrix * 2 - 1;

                uv.xy = mul(uv.xy, rMatrix);
                uv += center;

                result = uv;
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
                float uAbs = abs(i.uv.x - 0.5f);
                float vAbs = abs(i.uv.y - 0.5f);
                
                float rotation = _Rotation;
                float center = _Center;
                float2 uv = 0;

                rotateDegrees_float(float2(uAbs, vAbs), center, rotation, uv);
                
                fixed4 col = tex2D(_MainTex, uv);
                return col;
            }
            ENDCG
        }
    }
}
