// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShaders/OldTV" 
{
	Properties 
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_contour("Contour Size", float) = 1
		_vignette("Vignette Strength", float) = 1
		_intensity("Bright Intensity", float) = 0.5
	}

	CGINCLUDE
	#include "UnityCG.cginc"
						
	sampler2D _MainTex;
	float _contour;
	float _vignette;
	float _intensity;
			
	struct appdata_t
    {
        float4 vertex	: POSITION;
        float4 color	: COLOR;
        float2 uv		: TEXCOORD0;
    };
 
    struct v2f
    {
        half2 uv		: TEXCOORD0;
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
		uv *= 1.1;	
		uv.x *= 1.0 + pow((abs(uv.y) * _contour/7), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour/5), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv =  uv * 0.92 + 0.039;
		return uv;
	}

	fixed4 frag (v2f i) : COLOR
	{
		float2 uv = i.uv;
		uv = curve( uv );
   
		float4 sum = (float4)0;
		sum = tex2D(_MainTex,float2(round(uv.x * 640)/640, round(uv.y * 480)/480));

		float x = uv.x * uv.y * _Time.z * 1000 + 10;
		x = fmod(x, 20) * fmod(x, 150);
		float dx = fmod(x, 0.01f);

		float3 parasite = (float3)0;
		parasite = sum.rgb + sum.rgb * saturate(0.001 + dx.xxx * 100);

		float3 xxx = (float)0;
		xxx = tex2D(_MainTex, parasite + 0.033);

		float2 sclines;
		sincos(uv.y * 1111, sclines.x, sclines.y);
		parasite += sum.rgb * float3(sclines.x, sclines.y, sclines.x);
		parasite = lerp(sum, parasite, saturate(_intensity));

		sum.rgb += dot(sum.xyz * parasite.xyz + sum.rgb, 1.0f) * 0.5f;
	
		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		sum *= pow(vignette, _vignette/4);
	
		if (uv.x < 0.0 || uv.x > 1.0)
			sum = 0.025;
		if (uv.y < 0.0 || uv.y > 1.0)
			sum = 0.025;
				
		sum /= 2;

		return fixed4(sum * xxx, 1.0);
	}			
	
	ENDCG

	Subshader
	{
		Pass
		{
			ZTest Always
			Cull Off
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			ENDCG
		}
	}
	Fallback off
}