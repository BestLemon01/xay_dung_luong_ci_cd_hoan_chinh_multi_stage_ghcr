package com.quickbite.delivery;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.*;

@RestController
@RequestMapping("/api/v1/deliveries")
public class DeliveryController {
    private final Map<String, String> deliveryStatus = new HashMap<>();

    @PostMapping("/assign")
    public ResponseEntity<Map<String, Object>> assignDriver(@RequestParam String orderId, @RequestParam String driverName) {
        deliveryStatus.put(orderId, "DISPATCHED");
        Map<String, Object> res = new HashMap<>();
        res.put("deliveryId", UUID.randomUUID().toString());
        res.put("orderId", orderId);
        res.put("driver", driverName);
        res.put("status", "DISPATCHED");
        return ResponseEntity.ok(res);
    }

    @GetMapping("/{orderId}/status")
    public ResponseEntity<Map<String, String>> getStatus(@PathVariable String orderId) {
        Map<String, String> res = new HashMap<>();
        res.put("orderId", orderId);
        res.put("status", deliveryStatus.getOrDefault(orderId, "PENDING"));
        return ResponseEntity.ok(res);
    }
}
