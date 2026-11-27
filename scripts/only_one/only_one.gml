function only_one()
	{
	if (instance_number(object_index) > 1)
		{
		ggmr_crash("[only_one] There can only be one instance of " + object_get_name(object_index) + " at a time!");
		}
	}

/* Copyright 2024 Springroll Games / Yosi */