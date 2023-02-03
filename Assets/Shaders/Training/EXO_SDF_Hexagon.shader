Shader "EXO/SDF/Hexagon"
{
    Properties
    {
        _Diameter ("Diameter", Range(0, 1)) = 1
        _MainTex ("Main Texture", 2D) = "white" {}
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _OutlineWidth ("Outline Width", Range(0, 1)) = 0.1
        _OutlineSmooth ("Outline Smooth", Range(0, 10)) = 1
    }
    
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent"
        }
        
        Blend SrcAlpha OneMinusSrcAlpha
        Zwrite Off
        
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
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            half _Diameter;
            fixed4 _OutlineColor;
            half _OutlineWidth;
            half _OutlineSmooth;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float hexagonal_distance(float2 uv)
            {
                uv = abs(uv);
                return max(dot(uv, normalize(float2(1, 1.73))), uv.x);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = (i.uv - 0.5) * 2;
                float radius = _Diameter * 0.5 * 1.73;
                float hex_dist = hexagonal_distance(uv);
                float hex_mask = step(hex_dist, radius);

                float outline_mask = 1 - smoothstep(hex_dist - _OutlineWidth * 0.5 * _OutlineSmooth, hex_dist + _OutlineWidth * 0.5 * _OutlineSmooth, (1 - _OutlineWidth) * 0.5 * 1.73);
                
                float4 main_tex = tex2D(_MainTex, i.uv);
                float4 color = lerp(main_tex, _OutlineColor, outline_mask);
                return fixed4(color.rgb, hex_mask);
            }
            
            ENDCG
        }
    }
}
