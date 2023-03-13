// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/BlackContour" 
{
	Properties 
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_contour("Contour Size", float) = 1
		_vignette("Vignette Strength", float) = 1
	}
		
	CGINCLUDE
	#include "UnityCG.cginc"
						
	sampler2D _MainTex;
	float _contour;
	float _vignette;
			
	struct appdata_t
    {
        float4 vertex   : POSITION;
        float4 color    : COLOR;
        float2 uv : TEXCOORD0;
    };
 
    struct v2f
    {
        half2 uv  : TEXCOORD0;
        float4 vertex   : SV_POSITION;
        fixed4 color    : COLOR;
    };   
             
  	v2f vert(appdata_t i)
    {
        v2f o;
        o.vertex = UnityObjectToClipPos(i.vertex);
        o.uv = i.uv;
        o.color = i.color;               
        return o;
    }

    inline float2 curve(float2 uv)
	{
		uv = (uv - 0.5) * 2.0;
		uv  *= 1.1;	
		uv.x *= 1.0 + pow((abs(uv.y) * _contour/7), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour/5), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv =  uv * 0.92 + 0.039;
		return uv;
	}

	fixed4 frag (v2f i) : COLOR
	{
		float2 uv = i.uv.xy;
		uv = curve( uv );
   
		float4 sum = (float4)0;
		sum = tex2D(_MainTex,float2(uv.x, uv.y));

		float3 col = (float3)0;
		col.rgb = sum.xyz;
	
		col.r += 0.033 * sum.x;
		col.g += 0.033 * sum.y;
		col.b += 0.033 * sum.z;
		col = clamp(col * 0.6 + 0.4 * col * col, 0.08, 1.0);
	
		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		col *= pow(vignette, _vignette/4);
	
		if (uv.x < 0.0 || uv.x > 1.0)
			col = 0.025;
		if (uv.y < 0.0 || uv.y > 1.0)
			col = 0.025;
	
		return fixed4(col, 1.0);
	}

	ENDCG

	SubShader 
	{
		Pass 
		{
			ZTest Always

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma target 3.0
			ENDCG
		}
	}
	Fallback off
}
