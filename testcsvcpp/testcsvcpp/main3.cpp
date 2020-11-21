#include "DT_Hero_Config.h"

#include <iostream>
using namespace std;

void main3()
{
	auto pCfg = GetDT_Hero_Config().FindByKey1(123);
	if (pCfg != nullptr)
	{
		cout << pCfg->id << pCfg->type << pCfg->name << pCfg->desc << endl;
	}

	pCfg = GetDT_Hero_Config().FindByKey2(456, "asdf");
	if (pCfg != nullptr)
	{
		cout << pCfg->id << pCfg->type << pCfg->name << pCfg->desc << endl;
	}

}