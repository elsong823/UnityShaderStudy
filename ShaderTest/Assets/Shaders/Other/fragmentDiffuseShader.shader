Shader "MyShader/c6/fragmentDiffuseShader"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
	}
	SubShader
	{
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Lighting.cginc"
			#include "UnityCG.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
			};
			fixed4 _Diffuse;

			v2f vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
				o.worldNormal = mul(i.normal, (float3x3)_World2Object);

				return o;
			}

			fixed4 frag(in v2f i):SV_Target
			{
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				float diff = saturate( dot(normalize(_WorldSpaceLightPos0), normalize(i.worldNormal)) );
				fixed3 diffuse = _LightColor0 * _Diffuse * diff;
				return fixed4(ambient + diffuse , 1.0);
			}


			ENDCG
		}
	}
	Fallback "Diffuse"
}