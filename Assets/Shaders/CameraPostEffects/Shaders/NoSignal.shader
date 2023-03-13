Shader "MyShaders/NoSignal" {

	Properties
	{
		_MainTex("Base (RGB)", 2D) = "white" {}
		_noSignal("Base (RGB)", 2D) = "gray" {}
		_frequency("Frequency", float) = 0
		_contrast("Contrast", float) = 0
		_ghost("Ghost", float) = 0
		_contour("Contour Size", float) = 0
		_vignette("Vignette Strength", float) = 0
	}

	CGINCLUDE
	#include "UnityCG.cginc"

	uniform sampler2D _MainTex;
	uniform sampler2D _noSignal;
	float _frequency;
	float _contrast;
	float _ghost;
	float _contour;
	float _vignette;

	struct v2f
	{
		float4 position : SV_POSITION;
		float2 uv		: TEXCOORD0;
	};

	inline float2 curve(float2 uv)
	{
		uv = (uv - 0.5) * 2.0;
		uv *= 1.1;
		uv.x *= 1.0 + pow((abs(uv.y) * _contour / 7), 2.0);
		uv.y *= 1.0 + pow((abs(uv.x) * _contour / 5), 2.0);
		uv = (uv / 2.0) + 0.5;
		uv = uv * 0.92 + 0.039;
		return uv;
	}

	float rand(float3 co) 
	{
		return frac(sin(dot(co.xyz ,float3(13.1, 78.2, 45.5))) * 777);
	}

	float4 frag(v2f i) : SV_Target
	{
		float2 uv = i.uv.xy;
		uv = curve(uv);

		float4 sum = (float4)0;
		sum = tex2D(_MainTex, 0);

		float4 ns = (float4)0;
		ns = tex2D(_noSignal, 1 - uv);

		float dx = 1 - abs(distance(i.uv.x, _frequency));
		float dy = 1 - abs(distance(i.uv.y, _contrast));

		dy = ((int)(dy * 8)) / 8.0;
		i.uv.y += dy * 0.025 + rand(float3(dy, dy, dy)).r / 500;
		i.uv.x += dx * 0.025 + rand(float3(dx, dx, dx)).r / 500;

		float gray = (ns.r + ns.g + ns.b) / 3;

		if (dx > 0.99)
			uv.x = _frequency;

		i.uv.x = i.uv.x % 1;
		i.uv.y = i.uv.y % 1;

		float4 c = tex2D(_MainTex, i.uv);
		
		float bleed = tex2D(_MainTex, uv + float2(0.01, 0)).rgb;
		bleed += tex2D(_MainTex, i.uv + float2(0.02, 0.02)).r;
		bleed += tex2D(_MainTex, i.uv + float2(0.02, 0.02)).g;
		bleed += tex2D(_MainTex, i.uv + float2(0.02, 0.02)).b;
		bleed /= 6;
		
		float3 col = (float3)0;
		col.rgb = sum.xyz;

		col.r += 0.033 * sum.x;
		col.g += 0.033 * sum.y;
		col.b += 0.033 * sum.z;

		float vignette = (float)0;
		vignette = (10.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y));
		col *= pow(vignette, _vignette / 4);
#ifdef MONOCHROMA
		if (bleed > _ghost)
			ns *= fixed4(0, bleed * _frequency * _contrast, 0, 0);
#else
		if (bleed > _ghost)
			ns += fixed4(0, bleed * _frequency * _contrast, 0, 0);
#endif
		float x = ((int)(i.uv.x * 320)) / 320.0;
		float y = ((int)(i.uv.y * 240)) / 240.0;

		c += rand(float3(x, y, _frequency)) * _contrast / 5;

		if (uv.x < 0.0 || uv.x > 1.0)
			col = 0;
		if (uv.y < 0.0 || uv.y > 1.0)
			col = 0;

		return fixed4((ns + c) * col, 1.0);
	}

	ENDCG

	SubShader
	{
		Pass
		{
			ZTest Always 
			Cull Off 
			ZWrite Off

			CGPROGRAM
			#pragma vertex vert_img
			#pragma fragment frag
			#pragma fragmentoption ARB_precision_hint_fastest
			#pragma shader_feature MONOCHROMA
			ENDCG
		}
	}
	Fallback off
}