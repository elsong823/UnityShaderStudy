Shader "MyShader/c6/specularFragmentHalfShader"
{
	Properties
	{
		_Diffuse("Diffuse", Color) = (1.0, 1.0, 1.0, 1.0)
		_Specular("Specular", Color) = (1.0, 1.0, 1.0, 1.0)
		_Gloss("Gloss", Range(8, 256)) = 32
	}

	SubShader
	{
		Pass
		{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed3 worldNormal : NORMAL;
				float4 worldFragPos : TEXCOORD;
			};

			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

			v2f vert(in appdata_base i)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, i.vertex);
//				o.worldNormal = mul(i.normal, (float3x3)_World2Object);
				o.worldNormal = UnityObjectToWorldNormal(i.normal);
				o.worldFragPos = mul(_Object2World, i.vertex);

				return o;
			}

			fixed4 frag(in v2f i):SV_Target
			{
				fixed3 worldLight = normalize(UnityWorldSpaceLightDir(i.worldFragPos));
				fixed3 worldView = normalize(UnityWorldSpaceViewDir(i.worldFragPos));
				fixed3 worldNormal = normalize(i.worldNormal);
				fixed3 halfLight = normalize(worldLight + worldView);

				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;

				float diff = dot(worldLight, worldNormal) * 0.5 + 0.5;
				fixed3 diffuse = _LightColor0.rgb * _Diffuse * diff;

				float spec = pow(saturate(dot(halfLight, worldNormal)), _Gloss);
				fixed3 specular = _LightColor0.rgb * _Specular * spec;

				return fixed4(ambient + diffuse + specular, 1.0);
			}

			ENDCG
		}
	}

	Fallback "Diffuse"

}