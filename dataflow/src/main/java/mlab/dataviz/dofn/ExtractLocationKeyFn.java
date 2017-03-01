package mlab.dataviz.dofn;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.api.services.bigquery.model.TableRow;
import com.google.cloud.dataflow.sdk.transforms.DoFn;
import com.google.cloud.dataflow.sdk.values.KV;

public class ExtractLocationKeyFn extends DoFn<TableRow, KV<String, TableRow>> {
	private static final Logger LOG = LoggerFactory.getLogger(ExtractLocationKeyFn.class);
	
	public void processElement(ProcessContext c) throws Exception {
		TableRow row = c.element();
		String key = (String) row.get("location_key");
		if (key != null) {
			c.output(KV.of(key, row));
		} else {
			LOG.error("Key not found for row " + row);
		}
	}
}